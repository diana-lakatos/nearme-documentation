class Reservation < ActiveRecord::Base
  include Payable
  include Chargeable

  class NotFound < ActiveRecord::RecordNotFound; end
  class InvalidPaymentState < StandardError; end
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  inherits_columns_from_association([:company_id, :administrator_id, :creator_id], :listing)

  before_save :set_start_and_end
  before_create :store_platform_context_detail
  after_create :create_waiver_agreements
  after_create :copy_dimensions_template

  PAYMENT_STATUSES = {
    :paid => 'paid',
    :failed => 'failed',
    :pending => 'pending',
    :refunded => 'refunded',
    :unknown => 'unknown'
  }.freeze

  attr_accessor :payment_response_params

  belongs_to :administrator, -> { with_deleted }, class_name: "User"
  belongs_to :company, -> { with_deleted }
  belongs_to :creator, -> { with_deleted }, class_name: "User"
  belongs_to :credit_card
  belongs_to :instance
  belongs_to :listing, -> { with_deleted }, class_name: 'Transactable', foreign_key: 'transactable_id'
  belongs_to :owner, -> { with_deleted }, :class_name => "User", counter_cache: true
  belongs_to :platform_context_detail, :polymorphic => true
  belongs_to :payment_method
  belongs_to :recurring_booking
  has_many :user_messages, as: :thread_context
  has_many :waiver_agreements, as: :target
  has_many :additional_charges, as: :target
  accepts_nested_attributes_for :additional_charges

  has_many :payment_documents, as: :attachable, class_name: 'Attachable::PaymentDocument', dependent: :destroy
  accepts_nested_attributes_for :payment_documents

  has_many :periods, :class_name => "ReservationPeriod", :inverse_of => :reservation, :dependent => :destroy

  has_many :payments, as: :payable, dependent: :destroy

  has_one :billing_authorization, as: :reference
  has_many :reviews, as: :reviewable
  has_one :dimensions_template, as: :entity
  has_many :shipments, dependent: :destroy
  accepts_nested_attributes_for :shipments

  validates :transactable_id, :presence => true
  # the if statement for periods is needed to make .recover work - otherwise reservation would be considered not valid even though it is
  validates :periods, :length => { :minimum => 1 }, :if => lambda { self.deleted_at_changed? && self.periods.with_deleted.count.zero? }
  validates :quantity, :numericality => { :greater_than_or_equal_to => 1 }
  validates :owner_id, :presence => true, :unless => lambda { owner.present? }
  validates :rejection_reason, length: { maximum: 255 }
  validate :validate_all_dates_available, on: :create, :if => lambda { listing }
  validate :validate_booking_selection, on: :create, :if => lambda { listing }
  validate :validate_book_it_out, on: :create, :if => lambda { listing && !book_it_out_discount.to_i.zero? }
  validate :validate_exclusive_price, on: :create, :if => lambda { listing && !exclusive_price_cents.to_i.zero? }

  before_validation :set_minimum_booking_minutes, on: :create, if: lambda { listing }
  before_validation :set_currency, on: :create, if: lambda { listing }
  before_validation :set_default_payment_status, on: :create, if: lambda { listing }

  before_create :set_hours_to_expiration, if: lambda { listing }
  before_create :set_costs, if: lambda { listing }

  after_create :auto_confirm_reservation

  alias_method :seller_type_review_receiver, :creator
  alias_method :buyer_type_review_receiver, :owner

  def additional_charge_types
    listing.all_additional_charge_types
  end


  def build_additional_charges(attributes)
    act_ids = attributes.delete(:additional_charge_ids)
    additional_charge_types.get_mandatory_and_optional_charges(act_ids).uniq.map do |act|
      self.additional_charges.build(additional_charge_type_id: act.id, currency: currency)
    end
  end

  def perform_expiry!
    if unconfirmed? && !deleted?
      expire!

      # FIXME: This should be moved to a background job base class, as per ApplicationController.
      #        The event_tracker calls can be executed from the Job instance.
      #        i.e. Essentially compose this as a 'non-http request' controller.
      mixpanel_wrapper = AnalyticWrapper::MixpanelApi.new(AnalyticWrapper::MixpanelApi.mixpanel_instance, :current_user => owner)
      event_tracker = Analytics::EventTracker.new(mixpanel_wrapper, AnalyticWrapper::GoogleAnalyticsApi.new(owner))
      event_tracker.booking_expired(self)
      event_tracker.updated_profile_information(self.owner)
      event_tracker.updated_profile_information(self.host)
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::Expired, self.id)
    end
  end

  def schedule_expiry
    ReservationExpiryJob.perform_later(hours_to_expiration.to_i.hours, self.id) if hours_to_expiration.to_i > 0
  end

  def expiry_time
    created_at + hours_to_expiration.to_i.hours
  end

  def store_platform_context_detail
    self.platform_context_detail_type = PlatformContext.current.platform_context_detail.class.to_s
    self.platform_context_detail_id = PlatformContext.current.platform_context_detail.id
  end

  def administrator
    super.presence || creator
  end

  monetize :successful_payment_amount_cents, with_model_currency: :currency
  monetize :exclusive_price_cents, with_model_currency: :currency, allow_nil: true

  state_machine :state, initial: :unconfirmed do
    before_transition unconfirmed: :confirmed do |reservation, transaction|
      reservation.validate_all_dates_available
      if reservation.errors.empty? && reservation.payment_capture
        reservation.create_shipments!
        true
      else
        false
      end
    end
    after_transition unconfirmed: :confirmed, do: :set_confirmed_at
    after_transition confirmed: [:cancelled_by_guest, :cancelled_by_host], do: [:schedule_refund, :set_cancelled_at]
    after_transition unconfirmed: [:cancelled_by_guest, :expired, :rejected], do: [:schedule_void_payment], if: lambda { |r| r.billing_authorization.present? }

    event :confirm do
      transition unconfirmed: :confirmed
    end

    event :reject do
      transition unconfirmed: :rejected
    end

    event :host_cancel do
      transition confirmed: :cancelled_by_host
    end

    event :user_cancel do
      transition [:unconfirmed, :confirmed] => :cancelled_by_guest
    end

    event :expire do
      transition unconfirmed: :expired
    end
  end

  scope :on, lambda { |date|
    joins(:periods).
      where("reservation_periods.date" => date).
      where(:state => [:confirmed, :unconfirmed]).
      uniq
  }

  scope :no_recurring, lambda { where(recurring_booking_id: nil) }

  scope :past, lambda { where("ends_at < ?", Time.current)}
  scope :upcoming, lambda { where("ends_at >= ?", Time.current)}

  scope :visible, lambda {
    without_state(:cancelled_by_guest, :cancelled_by_host).upcoming
  }

  scope :not_archived, lambda {
    upcoming.without_state(:cancelled_by_guest, :cancelled_by_host, :rejected, :expired).uniq
  }

  scope :not_rejected_or_cancelled, lambda {
    without_state(:cancelled_by_guest, :cancelled_by_host, :rejected)
  }

  scope :cancelled, lambda {
    with_state(:cancelled_by_guest, :cancelled_by_host)
  }

  scope :confirmed_or_unconfirmed, lambda {
    with_state(:confirmed, :unconfirmed)
  }

  scope :confirmed, lambda {
    with_state(:confirmed)
  }

  scope :unconfirmed, lambda {
    with_state(:unconfirmed)
  }

  scope :rejected, lambda {
    with_state(:rejected)
  }

  scope :expired, lambda {
    with_state(:expired)
  }

  scope :cancelled_or_expired_or_rejected, lambda {
    with_state(:cancelled_by_guest, :cancelled_by_host, :rejected, :expired)
  }

  scope :archived, lambda {
    where('reservations.ends_at < ? OR reservations.state IN (?)', Time.current, ['rejected', 'expired', 'cancelled_by_host', 'cancelled_by_guest'])
  }

  scope :last_x_days, lambda { |days_in_past|
    where('DATE(reservations.created_at) >= ? ', days_in_past.days.ago)
  }

  scope :for_listing, ->(listing) {where(:transactable_id => listing.id)}

  scope :by_period, ->(start_date, end_date = Time.zone.today.end_of_day) {
    where(created_at: start_date..end_date)
  }

  scope :with_listing, -> {where.not(transactable_id: nil)}

  validates_presence_of :payment_method_id
  validates_presence_of :payment_status, :in => PAYMENT_STATUSES.values, :allow_blank => true

  delegate :location, :show_company_name, :transactable_type_id, :transactable_type, :billing_authorizations, to: :listing
  delegate :administrator=, to: :location
  delegate :favourable_pricing_rate, :service_fee_guest_percent, :service_fee_host_percent, to: :listing, allow_nil: true

  def authorize
    billing_gateway = self.payment_method.try(:payment_gateway)
    billing_gateway.present? ? billing_gateway.authorize(self) : false
  end

  def set_confirmed_at
    touch(:confirmed_at)
  end

  def set_cancelled_at
    touch(:cancelled_at)
  end

  def user=(value)
    self.owner = value
    self.confirmation_email = value.try(:email)
  end

  def user
    @user ||= creator
  end

  def host
    @host ||= creator
  end

  def date=(value)
    periods.build :date => value
  end

  def first_period
    periods.sort_by {|p| [p.date, p.start_minute] }.first
  end

  def last_period
    periods.sort_by {|p| [p.date, p.start_minute] }.last
  end

  def date
    first_period.date
  end

  def last_date
    periods.sort_by(&:date).last.date
  end

  def max_availability_for_booking_day
    listing.availability_for(date, first_period.start_minute, first_period.end_minute)
  end

  def cancelable?
    case
    when confirmed?, unconfirmed?
      # A reservation can be canceled if not already canceled and all of the dates are in the future
      cancellation_policy.cancelable?
    else
      false
    end
  end
  alias_method :cancelable, :cancelable?

  def cancellation_policy
    @cancellation_policy ||= Reservation::CancellationPolicy.new(self)
  end

  def owner_including_deleted
    User.unscoped { owner }
  end

  def reject(reason = nil)
    self.rejection_reason = reason if reason
    fire_state_event :reject
  end

  def archived?
    rejected? || cancelled? || (periods.all? {|p| p.date < Time.zone.today} || expired?)
  end

  def cancelled?
    cancelled_by_host? || cancelled_by_guest?
  end

  def add_period(date, start_minute = nil, end_minute = nil)
    periods.build :date => date, :start_minute => start_minute, :end_minute => end_minute
  end

  def booked_on?(date)
    periods.detect { |period| period.date == date }
  end

  #----- PRICE METHODS -----#

  def subtotal_amount_cents
    super || price_calculator.price.cents rescue nil
  end

  def shipping_amount_cents
    shipments.sum(:price)
  end

  def tax_amount_cents
    0
  end

  def price_in_cents
    subtotal_amount_cents / quantity
  end

  def total_amount_dollars
    total_amount_cents/Money::Currency.new(currency).subunit_to_unit.to_f
  end

  def total_negative_amount_dollars
    total_amount_dollars * -1
  end

  def successful_payment_amount_cents
    payments.paid.first.try(:total_amount_cents) || 0
  end

  # FIXME: This should be +balance_cents+ to conform to our conventions
  def balance
    successful_payment_amount_cents - total_amount_cents
  end

  def currency
    super.presence || listing.try(:currency)
  end

  #----- PRICE METHODS ENDS -----#

  def total_days
    periods.size
  end

  def total_nights
    price_calculator.number_of_nights
  end

  def total_units
    listing.overnight_booking? ? total_nights : total_days
  end

  # Number of desks booked accross all days
  def desk_days
    # NB: use of 'size' not 'count' here is deliberate - seats/periods may not be persisted at this point!
    (quantity || 0) * periods.size
  end

  def merchant_subject
    listing.company.paypal_express_chain_merchant_account.try(:subject)
  end

  def action_free_booking?
    total_amount.to_f <= 0
  end

  def has_service_fee?
    !service_fee_amount_guest.to_f.zero?
  end

  def paid?
    payment_status == PAYMENT_STATUSES[:paid]
  end

  def pending?
    payment_status == PAYMENT_STATUSES[:pending]
  end

  def should_expire!
    expire! if unconfirmed?
  end

  def to_liquid
    @reservation_drop ||= ReservationDrop.new(self)
  end

  def name
    date_first = date.strftime('%-e %b')
    date_last = last_date.strftime('%-e %b')
    dates_description = date_first == date_last ? date_first : "#{date_first}-#{date_last}"
    "Reservation of #{listing.try(:name)}, user: #{owner.try(:name)}, #{dates_description}"
  end

  def attempt_payment_refund(counter = 0)
    return if !(active_merchant_payment? && paid?)
    payment = payments.paid.first
    if payment.nil?
      raise InvalidPaymentState.new("[Refund] Reservation id=#{self.id} is marked as paid but payment has not been created - invalid state")
    else
      counter = counter + 1
      if payment.refund
        self.update_attribute(:payment_status, PAYMENT_STATUSES[:refunded])
      elsif counter < 3
        ReservationRefundJob.perform_later(Time.zone.now + (counter * 6).hours, self.id, counter)
      else
        Rails.application.config.marketplace_error_logger.log_issue(MarketplaceErrorLogger::BaseLogger::REFUND_ERROR, "Refund for Reservation id=#{self.id} failed 3 times, manual intervation needed.")
      end
    end
    true
  end

  def payment_capture
    return true if manual_payment? || total_amount_cents == 0

    if billing_authorization.present?
      attempt_payment_capture
      paid?
    elsif recurring_booking_id.present?
      schedule_payment_capture
      true
    else
      false
    end
  end

  def attempt_payment_capture
    return if !active_merchant_payment? || paid? || !unconfirmed?
    generate_payment
  end

  def charge
    return if paid?
    generate_payment
  end

  def generate_payment
    # Generates a Payment, which is a record of the charge incurred
    # by the user for the reservation (or a part of it), including the
    # gross amount and service fee components.
    #
    # NB: A future story is to separate out extended reservation payments
    #     across multiple payment dates, in which case a Reservation would
    #     have more than one Payment.
    #
    #
    payment = payments.build(
      subtotal_amount: subtotal_amount,
      service_fee_amount_guest: service_fee_amount_guest,
      service_fee_amount_host: service_fee_amount_host,
      service_additional_charges_cents: service_additional_charges_cents,
      host_additional_charges_cents: host_additional_charges_cents,
      cancellation_policy_hours_for_cancellation: cancellation_policy_hours_for_cancellation,
      cancellation_policy_penalty_percentage: cancellation_policy_penalty_percentage
    )
    payment.payment_response_params = payment_response_params
    payment.save!

    self.payment_status = if payment.paid?
                            PAYMENT_STATUSES[:paid]
                          else
                            PAYMENT_STATUSES[:failed]
                          end
    save!
  end

  def assigned_waiver_agreement_templates
    if listing.try(:assigned_waiver_agreement_templates).try(:any?)
      listing.assigned_waiver_agreement_templates.includes(:waiver_agreement_template).map(&:waiver_agreement_template)
    elsif listing.try(:location).try(:assigned_waiver_agreement_templates).try(:any?)
      listing.location.assigned_waiver_agreement_templates.includes(:waiver_agreement_template).map(&:waiver_agreement_template)
    else PlatformContext.current.instance.waiver_agreement_templates.any?
      PlatformContext.current.instance.waiver_agreement_templates
    end
  end

  def action_hourly_booking?
    reservation_type == 'hourly' || self.listing.schedule_booking?
  end

  def action_daily_booking?
    reservation_type == 'daily'
  end

  def validate_all_dates_available
    invalid_dates = periods.reject(&:bookable?)
    if invalid_dates.any?
      errors.add(:base, "Unfortunately the following bookings are no longer available: #{invalid_dates.map(&:as_formatted_string).join(', ')}")
    end
  end

  def create_shipments!
    CreateShippoShipmentsJob.perform(self.id) if shipments.any?
  end

  private


  def price_calculator
    @price_calculator ||= if listing.schedule_booking?
                            FixedPriceCalculator.new(self)
                          elsif action_hourly_booking?
                            HourlyPriceCalculator.new(self)
                          else
                            DailyPriceCalculator.new(self)
                          end
  end

  def auto_confirm_reservation
    confirm! unless listing.confirm_reservations?
  end

  def schedule_refund(transition, counter = 0, run_at = Time.zone.now)
    ReservationRefundJob.perform_later(run_at, self.id, counter)
  end

  def schedule_void_payment
    ReservationVoidPaymentJob.perform(self.id)
  end

  def schedule_payment_capture
    ReservationPaymentCaptureJob.perform_later(date + first_period.start_minute.minutes - recurring_booking.hours_before_reservation_to_charge.hours, self.id)
  end

  def create_waiver_agreements
    assigned_waiver_agreement_templates.each do |t|
      waiver_agreements.create(waiver_agreement_template: t, vendor_name: host.name, guest_name: owner.name)
    end
  end

  def copy_dimensions_template
    if listing.dimensions_template.present?
      copied_dimensions_template = listing.dimensions_template.dup
      copied_dimensions_template.entity = self
      copied_dimensions_template.save!
    end

    true
  end

  def fees_persisted?
    persisted?
  end

  # ----- SETTERS ------ #

  def set_currency
    self.currency ||= listing.try(:currency)
  end

  def set_costs
    self.subtotal_amount_cents = price_calculator.price.try(:cents)
    self.service_fee_amount_guest_cents = service_fee_amount_guest.try(:cents)
    self.service_fee_amount_host_cents = service_fee_amount_host.try(:cents)
  end

  def set_default_payment_status
    return if paid?

    self.payment_status = if action_free_booking?
                            PAYMENT_STATUSES[:paid]
                          else
                            PAYMENT_STATUSES[:pending]
                          end
  end

  def set_start_and_end
    self.starts_at = first_period.starts_at
    self.ends_at = last_period.ends_at
  end

  def set_hours_to_expiration
    self.hours_to_expiration = listing.hours_to_expiration
  end

  def set_minimum_booking_minutes
    self.minimum_booking_minutes = listing.minimum_booking_minutes
  end

  # VALIDATION METHODS

  def validate_booking_selection
    unless price_calculator.valid?
      if HourlyPriceCalculator === price_calculator
        errors.add(:base, "Booking selection does not meet requirements. A minimum of #{sprintf('%.2f', minimum_booking_minutes/60.0)} hours are required.")
      else
      errors.add(:base, "Booking selection does not meet requirements. A minimum of #{listing.minimum_booking_days} consecutive bookable days are required.")
      end
    end
  end

  def validate_book_it_out
    if max_availability_for_booking_day != quantity
      errors.add(:base, I18n.t('reservations_review.errors.book_it_out_quantity'))
    end
    unless listing.book_it_out_available? || quantity < listing.book_it_out_minimum_qty
      errors.add(:base, I18n.t('reservations_review.errors.book_it_out_not_available'))
    end
  end

  def validate_exclusive_price
    unless listing.exclusive_price_available?
      errors.add(:base, I18n.t('reservations_review.errors.exclusive_price_not_available'))
    end
  end

end
