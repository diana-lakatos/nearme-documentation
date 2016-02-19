class Reservation < ActiveRecord::Base

  include Chargeable

  class NotFound < ActiveRecord::RecordNotFound; end
  class InvalidPaymentState < StandardError; end
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  inherits_columns_from_association([:company_id, :administrator_id, :creator_id], :listing)

  belongs_to :administrator, -> { with_deleted }, class_name: "User"
  belongs_to :company, -> { with_deleted }
  belongs_to :creator, -> { with_deleted }, class_name: "User"
  belongs_to :credit_card
  belongs_to :instance
  belongs_to :listing, -> { with_deleted }, class_name: 'Transactable', foreign_key: 'transactable_id'
  belongs_to :owner, -> { with_deleted }, :class_name => "User", counter_cache: true
  belongs_to :platform_context_detail, :polymorphic => true
  belongs_to :recurring_booking

  has_one :billing_authorization, as: :reference
  has_one :dimensions_template, as: :entity
  has_one :payment, as: :payable

  has_many :user_messages, as: :thread_context
  has_many :waiver_agreements, as: :target
  has_many :additional_charges, as: :target
  has_many :payment_documents, as: :attachable, class_name: 'Attachable::PaymentDocument', dependent: :destroy
  has_many :periods, :class_name => "ReservationPeriod", :inverse_of => :reservation, :dependent => :destroy
  has_many :shipments, dependent: :destroy
  has_many :reviews, as: :reviewable

  accepts_nested_attributes_for :payment_documents
  accepts_nested_attributes_for :additional_charges
  accepts_nested_attributes_for :shipments

  validates :listing, :presence => true
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
  before_save :set_start_and_end

  before_create :store_platform_context_detail
  after_create :create_waiver_agreements
  after_create :copy_dimensions_template
  after_save :verify_authorization!

  alias_method :seller_type_review_receiver, :creator
  alias_method :buyer_type_review_receiver, :owner

  delegate :location, :show_company_name, :transactable_type_id, :transactable_type, :billing_authorizations, to: :listing
  delegate :administrator=, to: :location
  delegate :favourable_pricing_rate, :service_fee_guest_percent, :service_fee_host_percent, to: :listing, allow_nil: true
  delegate :remote_payment?, :manual_payment?, :active_merchant_payment?, :paid?, to: :payment, allow_nil: true

  monetize :successful_payment_amount_cents, with_model_currency: :currency
  monetize :exclusive_price_cents, with_model_currency: :currency, allow_nil: true

  state_machine :state, initial: :inactive do

    after_transition inactive: :unconfirmed, do: :activate_reservation!
    after_transition unconfirmed: :confirmed, do: :set_confirmed_at
    after_transition confirmed: [:cancelled_by_guest, :cancelled_by_host], do: [:set_cancelled_at, :schedule_refund]
    after_transition unconfirmed: [:cancelled_by_guest, :expired, :rejected], do: [:schedule_void], if: lambda { |r| r.payment.authorized? }

    event :activate                 do transition inactive: :unconfirmed; end
    event :confirm                  do transition unconfirmed: :confirmed; end
    event :reject                   do transition unconfirmed: :rejected; end
    event :host_cancel              do transition confirmed: :cancelled_by_host; end
    event :user_cancel              do transition [:unconfirmed, :confirmed] => :cancelled_by_guest; end
    event :expire                   do transition unconfirmed: :expired; end
  end

  scope :active, -> { without_state(:inactive) }
  scope :cancelled, -> { with_state(:cancelled_by_guest, :cancelled_by_host) }
  scope :confirmed, -> { with_state(:confirmed)}
  scope :confirmed_or_unconfirmed, -> { with_state(:confirmed, :unconfirmed) }
  scope :expired, -> { with_state(:expired) }
  scope :for_listing, -> (listing) { where(:transactable_id => listing.id) }
  scope :last_x_days, -> (days_in_past) { where('DATE(reservations.created_at) >= ? ', days_in_past.days.ago) }
  scope :no_recurring, -> { where(recurring_booking_id: nil) }
  scope :not_rejected_or_cancelled, -> { without_state(:cancelled_by_guest, :cancelled_by_host, :rejected, :inactive) }
  scope :past, -> { where("ends_at < ?", Time.current)}
  scope :rejected, -> { with_state(:rejected) }
  scope :unconfirmed, -> { with_state(:unconfirmed) }
  scope :upcoming, -> { where("ends_at >= ?", Time.current)}
  scope :visible, -> { without_state(:cancelled_by_guest, :cancelled_by_host, :inactive).upcoming }
  scope :with_listing, -> { where.not(transactable_id: nil) }

  scope :on, -> (date) {
    joins(:periods).
    where("reservation_periods.date" => date).
    where(:state => [:confirmed, :unconfirmed]).
    uniq
  }

  scope :not_archived, -> {
    upcoming.without_state(:cancelled_by_guest, :cancelled_by_host, :rejected, :expired, :inactive).uniq
  }

  scope :cancelled_or_expired_or_rejected, -> {
    with_state(:cancelled_by_guest, :cancelled_by_host, :rejected, :expired)
  }

  scope :archived, -> {
    where('reservations.ends_at < ? OR reservations.state IN (?)', Time.current, ['rejected', 'expired', 'cancelled_by_host', 'cancelled_by_guest'])
  }

  scope :by_period, -> (start_date, end_date = Time.zone.today.end_of_day) {
    where(created_at: start_date..end_date)
  }

  def archived?
    rejected? || cancelled? || (periods.all? {|p| p.date < Time.zone.today} || expired?)
  end

  def cancelled?
    cancelled_by_host? || cancelled_by_guest?
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

  def additional_charge_types
    listing.all_additional_charge_types
  end

  def build_additional_charges(attributes)
    act_ids = attributes.delete(:additional_charge_ids)
    additional_charge_types.get_mandatory_and_optional_charges(act_ids).uniq.map do |act|
      self.additional_charges.build(target: self, additional_charge_type_id: act.id, currency: currency)
    end
  end

  def charge_and_confirm!
    self.errors.clear
    self.validate_all_dates_available
    if self.errors.empty? && self.valid? && self.payment.capture!
      self.create_shipments!
      self.confirm!
    end
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

  def store_platform_context_detail
    self.platform_context_detail_type = PlatformContext.current.platform_context_detail.class.to_s
    self.platform_context_detail_id = PlatformContext.current.platform_context_detail.id
  end

  def administrator
    super.presence || creator
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

  def owner_including_deleted
    User.unscoped { owner }
  end

  def reject(reason = nil)
    self.rejection_reason = reason if reason
    fire_state_event :reject
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
    payment.try(:total_amount_cents) || 0
  end

  # FIXME: This should be +balance_cents+ to conform to our conventions
  def balance
    successful_payment_amount_cents - total_amount_cents
  end

  def currency
    super.presence || listing.try(:currency)
  end

  def express_return_url
    PlatformContext.current.decorate.build_url_for_path("/listings/#{self.listing.to_param}/reservations/return_express_checkout")
  end

  def express_cancel_return_url
    PlatformContext.current.decorate.build_url_for_path("/listings/#{self.listing.to_param}/reservations/cancel_express_checkout")
  end

  def line_items
    [self]
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

  def has_service_fee?
    !service_fee_amount_guest.to_f.zero?
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
    "Reservation of #{listing.try(:name)}, user: #{owner.try(:name)}, #{dates_description}"
  end

  def assigned_waiver_agreement_templates
    if listing.try(:assigned_waiver_agreement_templates).try(:any?)
      listing.assigned_waiver_agreement_templates.includes(:waiver_agreement_template).map(&:waiver_agreement_template)
    elsif listing.try(:location).try(:assigned_waiver_agreement_templates).try(:any?)
      listing.location.assigned_waiver_agreement_templates.includes(:waiver_agreement_template).map(&:waiver_agreement_template)
    else (templates = PlatformContext.current.instance.waiver_agreement_templates).any?
      templates
    end
  end

  def action_hourly_booking?
    reservation_type == 'hourly' || self.listing.schedule_booking?
  end

  def action_daily_booking?
    reservation_type == 'daily'
  end

  def is_free?
    total_amount.to_f <= 0
  end

  def create_shipments!
    CreateShippoShipmentsJob.perform(self.id) if shipments.any?
  end

  def validate_all_dates_available
    invalid_dates = periods.reject(&:bookable?)
    if invalid_dates.any?
      errors.add(:base, "Unfortunately the following bookings are no longer available: #{invalid_dates.map(&:as_formatted_string).join(', ')}")
    end
  end

  def build_payment(payment_attributes={})
    super(
      payment_attributes.merge(
        {
          company: company,
          currency: currency,
          subtotal_amount_cents: subtotal_amount.try(:cents) || 0,
          service_fee_amount_guest_cents: service_fee_amount_guest.try(:cents) || 0,
          service_fee_amount_host_cents: service_fee_amount_host.try(:cents) || 0,
          service_additional_charges_cents: service_additional_charges.try(:cents) || 0,
          host_additional_charges_cents: host_additional_charges.try(:cents) || 0,
          cancellation_policy_hours_for_cancellation: cancellation_policy_hours_for_cancellation,
          cancellation_policy_penalty_percentage: cancellation_policy_penalty_percentage,
          payable: self
        }
      )
    )
  end

  def calculate_prices
    self.subtotal_amount_cents = price_calculator.price.try(:cents)
    self.service_fee_amount_guest_cents = service_fee_amount_guest.try(:cents)
    self.service_fee_amount_host_cents = service_fee_amount_host.try(:cents)
  end

  private

  def activate_reservation!
    schedule_expiry
    auto_confirm_reservation
    pre_booking_job
    first_booking_job
  end

  def pre_booking_job
    pre_booking_sending_date = (self.date - 1.day).in_time_zone + 17.hours # send day before at 5pm
    if pre_booking_sending_date < Time.current.beginning_of_day
      ReservationPreBookingJob.perform_later(pre_booking_sending_date, self.id)
    end
  end

  def first_booking_job
    if self.user.reservations.active.count == 1
      ReengagementOneBookingJob.perform_later(self.last_date.in_time_zone + 7.days, self.id)
    end
  end

  def auto_confirm_reservation
    if listing.confirm_reservations?
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::CreatedWithoutAutoConfirmation, self.id)
    else
      charge_and_confirm!
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::CreatedWithAutoConfirmation, self.id)
    end
  end

  def price_calculator
    if listing.schedule_booking?
      FixedPriceCalculator.new(self)
    elsif action_hourly_booking?
      HourlyPriceCalculator.new(self)
    else
      DailyPriceCalculator.new(self)
    end
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

  def verify_authorization!
    if inactive? && payment.authorized?
      activate!
    end
  end

  # ----- SCHEDULERS -------
  def schedule_expiry
    hours_to_expiration = listing.hours_to_expiration.to_i.hours
    self.update_column(:expire_at, Time.current + hours_to_expiration)
    ReservationExpiryJob.perform_later(self.reload.expire_at, self.id) if hours_to_expiration > 0
  end

  def schedule_refund(transition, run_at = Time.zone.now)
    PaymentRefundJob.perform_later(run_at, payment.id)
  end

  def schedule_void
    PaymentVoidJob.perform(payment.id)
  end

  # ----- SETTERS ---------
  def set_currency
    self.currency ||= listing.try(:currency)
  end

  def set_start_and_end
    self.starts_at = first_period.starts_at
    self.ends_at = last_period.ends_at
  end

  def set_minimum_booking_minutes
    self.minimum_booking_minutes = listing.minimum_booking_minutes
  end

  # ----- VALIDATIONS ------

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
