# frozen_string_literal: true
class Reservation < Order
  include Bookable
  include Categorizable

  belongs_to :transactable_pricing, -> { with_deleted }, class_name: 'Transactable::Pricing'

  has_one :transactable_line_item, class_name: 'LineItem::Transactable', as: :line_itemable
  has_one :old_reservation, foreign_key: 'order_id', inverse_of: :reservation

  accepts_nested_attributes_for :periods, allow_destroy: true

  validates :transactable, presence: true
  validates :transactable_pricing, presence: true

  # the if statement for periods is needed to make .recover work - otherwise reservation would be considered not valid even though it is

  validates :owner_id, presence: true, unless: -> { owner.present? }
  validates :rejection_reason, length: { maximum: 255 }
  validate :address_in_radius?, if: -> { address_in_radius }
  validate :validate_order_for_action, on: :create, if: -> { transactable }

  before_create :set_cancellation_policy

  alias seller_type_review_receiver creator
  alias buyer_type_review_receiver user

  delegate :location, :show_company_name, :transactable_type_id, :transactable_type, to: :transactable
  delegate :administrator=, to: :location
  delegate :favourable_pricing_rate, :service_fee_guest_percent, :service_fee_host_percent, :minimum_lister_service_fee_cents, to: :action, allow_nil: true
  delegate :display_additional_charges?, to: :transactable, allow_nil: true
  delegate :address_in_radius, to: :reservation_type, allow_nil: true
  delegate :event_booking?, to: :transactable_pricing

  state_machine :state, initial: :inactive do
    after_transition confirmed: [:cancelled_by_guest], do: [:charge_penalty!]
    after_transition unconfirmed: :confirmed, do: [:warn_user_of_expiration]
  end

  scope :for_transactable, -> (transactable) { where(transactable_id: transactable.id) }

  def add_line_item!(attrs)
    self.attributes = attrs
    self.book_it_out_discount = transactable_pricing.book_it_out_discount if attrs[:book_it_out] == 'true'
    self.reservation_type = transactable.transactable_type.reservation_type
    build_periods
    set_minimum_booking_minutes
    self.skip_checkout_validation = true
    self.settings = reservation_type.try(:settings)
    save
  end

  def self.workflow_class
    Reservation
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

  def cancelable?
    return false if can_approve_or_decline_checkout? || has_to_update_credit_card? || archived_at.present?
    if confirmed? || unconfirmed?
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

  def invoke_confirmation!(&_block)
    errors.clear
    action.try(:validate_all_dates_available, self) unless skip_payment_authorization?
    schedule_expiry if action.both_side_confirmation && (lister_confirmed_at.nil? || enquirer_confirmed_at.nil?)
    if errors.empty? && valid? && check_double_confirmation
      if block_given? ? yield : true
        process_deliveries!
        confirm!
        # We need to touch transactable so it's reindexed by ElasticSearch
        transactable.touch
      end
    end
  end

  def check_double_confirmation
    !action.both_side_confirmation || (lister_confirmed_at.present? && enquirer_confirmed_at.present?)
  end

  def charge_and_confirm!
    invoke_confirmation! do
      payment.capture!
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
      raise('Charging penalty when there exist already authorized/paid payment!') if payment.present? && (payment.paid? || payment.authorized?)
      line_items.where.not(id: transactable_line_item.id).destroy_all

      transactable_line_item.update_columns(unit_price_cents: penalty_fee_subtotal.cents, quantity: 1, name: 'Cancellation Penalty')
      reload
      transactable_line_item.build_service_fee.try(:save!)
      transactable_line_item.build_host_fee.try(:save!)
      update_payment_attributes
      payment.payment_transfer.try(:send, :assign_amounts_and_currency)
      if payment.authorize && payment.capture!
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::PenaltyChargeSucceeded, id)
      else
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::PenaltyChargeFailed, id)
      end
    end
    true
  end

  def penalty_fee_subtotal
    transactable_line_item.unit_price * cancellation_policy_penalty_hours
  end

  def penalty_fee
    penalty_fee_subtotal + (penalty_fee_subtotal * service_fee_guest_percent.to_f / BigDecimal(100))
  end

  def perform_expiry!
    if unconfirmed? && !deleted?
      expire!
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::Expired, id)
    end
  end

  def date=(value)
    periods.build date: value
  end

  def first_period
    periods.sort_by { |p| [p.date, p.start_minute] }.first
  end

  def last_period
    periods.sort_by { |p| [p.date, p.start_minute] }.last
  end

  def last_date
    periods.sort_by(&:date).last.date
  end

  def period_range
    { from: first_period.date, to: last_period.date }
  end

  def owner_including_deleted
    User.unscoped { owner }
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

  # @return [Boolean] whether hourly booking is available for this reservation
  def action_hourly_booking?
    !transactable_pricing.is_free_booking? && transactable_pricing.hour_booking?
  end

  def action_daily_booking?
    !transactable_pricing.is_free_booking? && transactable_pricing.day_booking?
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

  def warn_user_of_expiration
    tt_action_type = transactable.try(:action_type).try(:transactable_type_action_type)
    if ends_at.present? && tt_action_type.try(:type) == 'TransactableType::TimeBasedBooking' &&
       tt_action_type.send_alert_hours_before_expiry &&
       tt_action_type.send_alert_hours_before_expiry_hours > 0

      WarnUserOfExpirationJob.perform_later(ends_at - tt_action_type.send_alert_hours_before_expiry_hours.hours, id)
    end

    true
  end

  private

  def auto_confirm_reservation
    if transactable.confirm_reservations?
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::CreatedWithoutAutoConfirmation, id)
    else
      charge_and_confirm!
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::CreatedWithAutoConfirmation, id)
    end
  end

  # ----- VALIDATIONS ------

  def validate_order_for_action
    transactable_pricing.validate_order(self)
  end

  # TODO: move to action
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
