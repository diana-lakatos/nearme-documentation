class Reservation < Order

  include Bookable
  include Categorizable

  belongs_to :transactable_pricing, class_name: 'Transactable::Pricing'

  has_one :transactable_line_item, class_name: 'LineItem::Transactable', as: :line_itemable
  has_one :old_reservation, foreign_key: 'order_id', inverse_of: :reservation

  accepts_nested_attributes_for :periods, allow_destroy: true

  validates :transactable, :presence => true
  validates :transactable_pricing, :presence => true

  # the if statement for periods is needed to make .recover work - otherwise reservation would be considered not valid even though it is

  validates :owner_id, :presence => true, :unless => lambda { owner.present? }
  validates :rejection_reason, length: { maximum: 255 }
  validate :address_in_radius?, :if => lambda { address_in_radius }
  validate :validate_order_for_action, on: :create, :if => lambda { transactable }

  before_create :set_cancellation_policy

  alias_method :seller_type_review_receiver, :creator
  alias_method :buyer_type_review_receiver, :user

  delegate :location, :show_company_name, :transactable_type_id, :transactable_type, to: :transactable
  delegate :administrator=, to: :location
  delegate :action, to: :transactable_pricing
  delegate :favourable_pricing_rate, :service_fee_guest_percent, :service_fee_host_percent, to: :action, allow_nil: true
  delegate :display_additional_charges?, to: :transactable, allow_nil: true
  delegate :address_in_radius, to: :reservation_type, allow_nil: true

  state_machine :state, initial: :inactive do
    after_transition confirmed: [:cancelled_by_guest], do: [:charge_penalty!]

    event :refund do transition :paid => :refunded; end
  end

  scope :for_transactable, -> (transactable) { where(:transactable_id => transactable.id) }

  def add_line_item!(attrs)
    self.attributes = attrs
    self.book_it_out_discount = transactable_pricing.book_it_out_discount if attrs[:book_it_out] == 'true'
    self.reservation_type = transactable.transactable_type.reservation_type
    self.build_periods
    self.set_minimum_booking_minutes
    self.skip_checkout_validation = true
    self.settings = reservation_type.try(:settings)
    self.save
  end

  def build_periods
    return if @dates.nil?
    if transactable
      if transactable_pricing.hour_booking? || transactable_pricing.event_booking?
        set_start_minute
        @start_minute = start_minute.try(:to_i)
        @end_minute = end_minute.try(:to_i)
      else
        @start_minute = nil
        @end_minute   = nil
      end

      if transactable_pricing.event_booking?
        if @dates.is_a?(String)
          timestamp = Time.at(@dates.to_i).in_time_zone(transactable.timezone)
          @start_minute = timestamp.try(:min).to_i + (60 * timestamp.try(:hour).to_i)
          @end_minute = @start_minute
          @dates = [timestamp.try(:to_date).try(:to_s)]
        end
      else
        @dates = @dates.split(',')
        @dates = @dates.take(1) if transactable_pricing.hour_booking?
      end
      @dates.flatten!
      @dates.reject(&:blank?).each do |date_string|
        begin
          date = Date.parse(date_string)
        rescue
          errors.add(:base, I18n.t('reservations_review.errors.invalid_date'))
          return
        end
        periods.build(date: date, start_minute: @start_minute, end_minute: @end_minute)
      end
    end
  end

  def set_start_minute
    return unless start_time && start_time.split(':').any?
    hours, minutes = start_time.split(':')

    self.start_minute = hours.to_i * 60 + minutes.to_i
    self.end_minute = start_minute + minimum_booking_minutes
  end

  def archived?
    archived_at.present?
  end

  def cancelable?
    return false if can_approve_or_decline_checkout? || has_to_update_credit_card? || archived_at.present?
    case
    when confirmed?, unconfirmed?
      # A reservation can be canceled if not already canceled and all of the dates are in the future
      cancellation_policy.cancelable?
    else
      false
    end
  end
  alias cancelable cancelable?

  def cancellation_policy
    @cancellation_policy ||= Reservation::CancellationPolicy.new(self)
  end

  def invoke_confirmation!(&block)
    self.errors.clear
    unless skip_payment_authorization?
      action.try(:validate_all_dates_available, self)
    end
    if self.errors.empty? && self.valid?
      if block_given? ? yield : true
        self.create_shipments!
        self.confirm!
        # We need to touch transactable so it's reindexed by ElasticSearch
        self.transactable.touch
      end
    end
  end

  def charge_and_confirm!
    invoke_confirmation! do
      self.payment.capture!
    end
  end

  def penalty_charge_apply?
    if skip_payment_authorization? && (confirmed? || cancelled_by_guest?) && cancellation_policy_penalty_hours > 0 && time_to_cancelation_has_expired?
      true
    else
      false
    end
  end

  def time_to_cancelation_has_expired?
    latest_time_to_cancel_without_fee = starts_at - cancellation_policy_hours_for_cancellation.to_i.hours
    if Time.zone.now > latest_time_to_cancel_without_fee
      true
    else
      false
    end
  end

  def charge_penalty!
    if penalty_charge_apply?
      fail('Charging penalty when there exist already authorized/paid payment!') if payment.present? && (payment.paid? || payment.authorized?)
      self.update_column(:subtotal_amount_cents, penalty_fee_subtotal.cents)
      self.force_recalculate_fees = true
      self.update_columns({
        service_fee_amount_guest_cents: self.service_fee_amount_guest.cents,
        service_fee_amount_host_cents: self.service_fee_amount_host.cents
      })
      # note: this might not work with shipment?
      self.payment.update_attributes({
        subtotal_amount_cents: self.subtotal_amount.cents,
        service_fee_amount_guest_cents: self.service_fee_amount_guest.cents,
        service_fee_amount_host_cents: self.service_fee_amount_host.cents,
        service_additional_charges_cents: self.service_additional_charges.cents,
        host_additional_charges_cents: self.host_additional_charges.cents
      })
      self.payment.payment_transfer.try(:send, :assign_amounts_and_currency)
      if self.payment.authorize && self.payment.capture!
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::PenaltyChargeSucceeded, self.id)
      else
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::PenaltyChargeFailed, self.id)
      end
    end
    true
  end

  def penalty_fee_subtotal
    unit_price * cancellation_policy_penalty_hours
  end

  def penalty_fee
    penalty_fee_subtotal + (penalty_fee_subtotal * service_fee_guest_percent.to_f / BigDecimal(100))
  end

  def perform_expiry!
    if unconfirmed? && !deleted?
      expire!

      # FIXME: This should be moved to a background job base class, as per ApplicationController.
      #        The event_tracker calls can be executed from the Job instance.
      #        i.e. Essentially compose this as a 'non-http request' controller.
      mixpanel_wrapper = AnalyticWrapper::MixpanelApi.new(AnalyticWrapper::MixpanelApi.mixpanel_instance, :current_user => owner)
      event_tracker = Rails.application.config.event_tracker.new(mixpanel_wrapper, AnalyticWrapper::GoogleAnalyticsApi.new(owner))
      event_tracker.booking_expired(self)
      event_tracker.updated_profile_information(self.owner)
      event_tracker.updated_profile_information(self.host)
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::Expired, self.id)
    end
  end

  def date=(value)
    periods.build date: value
  end

  def first_period
    periods.sort_by {|p| [p.date, p.start_minute] }.first
  end

  def last_period
    periods.sort_by {|p| [p.date, p.start_minute] }.last
  end

  def last_date
    periods.sort_by(&:date).last.date
  end

  def owner_including_deleted
    User.unscoped { owner }
  end

  def reject(reason = nil)
    self.rejection_reason = reason if reason
    fire_state_event :reject
  end

  def add_period(date, start_minute = nil, end_minute = nil)
    periods.build(date: date, start_minute: start_minute, end_minute: end_minute)
  end

  def booked_on?(date)
    periods.detect { |period| period.date == date }
  end

  def total_days
    periods.size
  end

  def total_nights
    total_days > 1 ? total_days - 1 : total_days
  end

  def total_units
    transactable_pricing.night_booking? ? total_nights : total_days
  end

  def should_expire!
    expire! if unconfirmed?
  end

  def to_liquid
    @reservation_drop ||= ReservationDrop.new(self)
  end

  def name
    date_first = I18n.l(date, format: :day_and_month)
    date_last = I18n.l(last_date, format: :day_and_month)
    dates_description = date_first == date_last ? date_first : "#{date_first}-#{date_last}"
    "Reservation of #{transactable.try(:name)}, user: #{owner.try(:name)}, #{dates_description}"
  end

  def action_hourly_booking?
    !transactable_pricing.is_free_booking? && transactable_pricing.hour_booking?
  end

  def action_daily_booking?
    !transactable_pricing.is_free_booking? && transactable_pricing.day_booking?
  end

  def event_booking?
    transactable_pricing.event_booking?
  end

  def can_complete_checkout?
    archived_at.nil? && skip_payment_authorization? && (payment.pending? || payment.voided?) && pending_guest_confirmation.nil?
  end

  def can_approve_or_decline_checkout?
    archived_at.nil? && skip_payment_authorization? && pending_guest_confirmation.present? && payment.authorized?
  end

  def has_to_update_credit_card?
    archived_at.nil? && skip_payment_authorization? && (payment.pending? || payment.voided?) && pending_guest_confirmation.present?
  end

  def can_confirm?
    super && archived_at.nil?
  end

  def max_availability_for_booking_day
    transactable.availability_for(date, first_period.start_minute, first_period.end_minute)
  end

  def price_calculator
    @price_calculator ||= transactable_pricing.price_calculator(self)
  end

  def set_minimum_booking_minutes
    self.minimum_booking_minutes = action.minimum_booking_minutes
  end

  private

  def auto_confirm_reservation
    if transactable.confirm_reservations?
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::CreatedWithoutAutoConfirmation, self.id)
    else
      charge_and_confirm!
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::CreatedWithAutoConfirmation, self.id)
    end
  end

  # ----- VALIDATIONS ------

  def validate_order_for_action
    transactable_pricing.validate_order(self)
  end


  #TODO: move to action
  def address_in_radius?
    distance = transactable.location_address.distance_from(address.latitude, address.longitude)
    if distance > transactable.properties[:service_radius].to_i
      errors.add(:base, I18n.t('errors.messages.not_in_radius'))
      address.errors.add(:address, I18n.t('errors.messages.not_in_radius'))
    end
  rescue
    false
  end

  def set_cancellation_policy
    if transactable_pricing.action && transactable_pricing.action.cancellation_policy_enabled.present?
      self.cancellation_policy_hours_for_cancellation = transactable_pricing.action.cancellation_policy_hours_for_cancellation
      self.cancellation_policy_penalty_hours = transactable_pricing.action.cancellation_policy_penalty_hours
      self.cancellation_policy_penalty_percentage = transactable_pricing.action.cancellation_policy_penalty_percentage
    end
  end

end
