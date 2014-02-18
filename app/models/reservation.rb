class Reservation < ActiveRecord::Base
  class NotFound < ActiveRecord::RecordNotFound; end
  has_paper_trail
  acts_as_paranoid
  include Reservation::RedundantDataSynchronizer
  PAYMENT_METHODS = {
    :credit_card => 'credit_card',
    :manual      => 'manual',
    :free        => 'free'
  }

  PAYMENT_STATUSES = {
    :paid => 'paid',
    :failed => 'failed',
    :pending => 'pending',
    :refunded => 'refunded',
    :unknown => 'unknown'
  }

  belongs_to :instance
  belongs_to :listing
  belongs_to :owner, :class_name => "User"
  belongs_to :creator, class_name: "User"
  belongs_to :administrator, class_name: "User"
  belongs_to :platform_context_detail, :polymorphic => true
  has_one :company, through: :listing
  has_many :user_messages, as: :thread_context

  attr_accessible :cancelable, :confirmation_email, :date, :listing_id,
    :owner_id, :periods, :state, :user, :comment, :quantity, :payment_method, :rejection_reason

  has_many :reviews, 
    :class_name => 'GuestRating', 
    :inverse_of => :reservation, 
    :dependent => :destroy

  has_many :comments_about_guests, 
    :class_name => 'HostRating', 
    :inverse_of => :reservation, 
    :dependent => :destroy

  has_many :periods,
           :class_name => "ReservationPeriod",
           :inverse_of => :reservation,
           :dependent => :destroy

  has_many :reservation_charges,
    inverse_of: :reservation,
    dependent: :destroy

  validates :listing_id, :presence => true
  # the if statement for periods is needed to make .recover work - otherwise reservation would be considered not valid even though it is
  validates :periods, :length => { :minimum => 1 }, :if => lambda { self.deleted_at_changed? && self.periods.with_deleted.count.zero? }
  validates :quantity, :numericality => { :greater_than_or_equal_to => 1 }
  validates :owner_id, :presence => true, :unless => lambda { owner.present? }
  validate :validate_all_dates_available, on: :create, :if => lambda { listing }
  validate :validate_booking_selection, on: :create, :if => lambda { listing }

  before_create :set_costs, :if => lambda { listing }
  before_validation :set_currency, on: :create, :if => lambda { listing }
  before_validation :set_default_payment_status, on: :create, :if => lambda { listing }
  after_create :auto_confirm_reservation

  def perform_expiry!
    if unconfirmed? && !deleted?
      expire!

      # FIXME: This should be moved to a background job base class, as per ApplicationController.
      #        The event_tracker calls can be executed from the Job instance.
      #        i.e. Essentially compose this as a 'non-http request' controller.
      platform_context = PlatformContext.new(platform_context_detail)
      mixpanel_wrapper = AnalyticWrapper::MixpanelApi.new(AnalyticWrapper::MixpanelApi.mixpanel_instance, :current_user => owner, 
                                                          :request_details  => { :current_instance_id => platform_context.instance.id }
                                                         )
      event_tracker = Analytics::EventTracker.new(mixpanel_wrapper, AnalyticWrapper::GoogleAnalyticsApi.new(owner))
      event_tracker.booking_expired(self)
      event_tracker.updated_profile_information(self.owner)
      event_tracker.updated_profile_information(self.host)

      ReservationMailer.notify_guest_of_expiration(platform_context, self).deliver
      ReservationMailer.notify_host_of_expiration(platform_context, self).deliver
    end
  end

  def schedule_expiry
    Delayed::Job.enqueue Delayed::PerformableMethod.new(self, :perform_expiry!, nil), run_at: expiry_time
  end

  def listing # fetch with deleted listing
    Listing.unscoped { super }
  end

  def administrator
    super.presence || creator
  end

  monetize :total_amount_cents
  monetize :subtotal_amount_cents
  monetize :service_fee_amount_guest_cents
  monetize :service_fee_amount_host_cents
  monetize :successful_payment_amount_cents

  state_machine :state, :initial => :unconfirmed do
    after_transition :unconfirmed => :confirmed, :do => :attempt_payment_capture
    after_transition :confirmed => [:cancelled_by_guest, :cancelled_by_host], :do => :schedule_refund

    event :confirm do
      transition :unconfirmed => :confirmed
    end

    event :reject do
      transition :unconfirmed => :rejected
    end

    event :host_cancel do
      transition :confirmed => :cancelled_by_host
    end

    event :user_cancel do
      transition [:unconfirmed, :confirmed] => :cancelled_by_guest
    end

    event :expire do
      transition :unconfirmed => :expired
    end
  end

  scope :on, lambda { |date|
    joins(:periods).
      where("reservation_periods.date" => date).
      where(:state => [:confirmed, :unconfirmed]).
      uniq
  }

  scope :upcoming, lambda {
    joins(:periods).
      where('reservation_periods.date >= ?', Time.zone.today).
      uniq
  }

  scope :past, lambda {
    joins(:periods).
      where('reservation_periods.date < ?', Time.zone.today).
      uniq
  }

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

  scope :confirmed, lambda {
    with_state(:confirmed)
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
    joins(:periods).where('reservation_periods.date < ? OR reservations.state IN (?)', Time.zone.today, ['rejected', 'expired', 'cancelled_by_host', 'cancelled_by_guest']).uniq
  }

  scope :last_x_days, lambda { |days_in_past|
    where('DATE(reservations.created_at) >= ? ', days_in_past.days.ago)
  }

  scope :for_listing, ->(listing) {where(:listing_id => listing.id)}

  scope :for_instance, ->(instance) { includes(:instance).joins(:instance).where(:'instances.id' => instance.id) }


  validates_presence_of :payment_method, :in => PAYMENT_METHODS.values
  validates_presence_of :payment_status, :in => PAYMENT_STATUSES.values, :allow_blank => true

  delegate :location, to: :listing
  delegate :creator=, :instance=, to: :company
  delegate :administrator=, to: :location
  delegate :service_fee_guest_percent, to: :listing, allow_nil: true
  delegate :service_fee_host_percent, to: :listing, allow_nil: true

  def user=(value)
    self.owner = value
    self.confirmation_email = value.try(:email)
  end

  def host
    @host ||= creator
  end

  def date=(value)
    periods.build :date => value
  end

  def date
    periods.sort_by(&:date).first.date
  end

  def last_date
    periods.sort_by(&:date).last.date
  end

  def cancelable?
    case
    when confirmed?, unconfirmed?
      # A reservation can be canceled if not already canceled and all of the dates are in the future
      !started?
    else
      false
    end
  end
  alias_method :cancelable, :cancelable?

  def owner_including_deleted
    User.unscoped { owner }
  end

  def reject(reason = nil)
    self.rejection_reason = reason if reason
    fire_state_event :reject
  end

  # Returns whether any of the reserved dates have started
  def started?
    periods.any? { |p| p.date <= Time.zone.today }
  end

  def archived?
    rejected? or cancelled? or periods.all? {|p| p.date < Time.zone.today}
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

  def total_amount_cents
    subtotal_amount_cents + service_fee_amount_guest_cents rescue nil
  end

  def subtotal_amount_cents
    super || price_calculator.price.cents rescue nil
  end

  def service_fee_amount_guest_cents
    super || service_fee_calculator.service_fee_guest.cents rescue nil
  end

  def service_fee_amount_host_cents
    super || service_fee_calculator.service_fee_host.cents rescue nil
  end

  def total_amount_dollars
    total_amount_cents/100.0
  end

  def total_negative_amount_dollars
    total_amount_dollars * -1
  end

  def total_days
    periods.size
  end

  # Number of desks booked accross all days
  def desk_days
    # NB: use of 'size' not 'count' here is deliberate - seats/periods may not be persisted at this point!
    (quantity || 0) * periods.size
  end

  def successful_payment_amount_cents
    reservation_charges.paid.first.try(:total_amount_cents) || 0
  end

  # FIXME: This should be +balance_cents+ to conform to our conventions
  def balance
    successful_payment_amount_cents - total_amount_cents
  end

  def credit_card_payment?
    payment_method == Reservation::PAYMENT_METHODS[:credit_card]
  end

  def manual_payment?
    payment_method == Reservation::PAYMENT_METHODS[:manual]
  end

  def currency
    super.presence || listing.try(:currency)
  end

  def free?
    total_amount <= 0
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

  def expiry_time
    created_at + 24.hours
  end

  def to_liquid
    ReservationDrop.new(self)
  end

  def name
    date_first = date.strftime('%-e %b')
    date_last = last_date.strftime('%-e %b')
    dates_description = date_first == date_last ? date_first : "#{date_first}-#{date_last}"
    "Reservation of #{listing.try(:name)}, user: #{owner.try(:name)}, #{dates_description}"
  end 

  private

    def service_fee_calculator
      @service_fee_calculator ||= Reservation::ServiceFeeCalculator.new(self)
    end

    def price_calculator
      @price_calculator ||= if listing.hourly_reservations?
        HourlyPriceCalculator.new(self)
      else
        DailyPriceCalculator.new(self)
      end
    end

    def set_default_payment_status
      return if paid?

      self.payment_status = if free?
        PAYMENT_STATUSES[:paid]
      else
        PAYMENT_STATUSES[:pending]
      end
    end

    def set_costs
      self.subtotal_amount_cents = price_calculator.price.try(:cents)
      if credit_card_payment?
        self.service_fee_amount_guest_cents = service_fee_calculator.service_fee_guest.try(:cents)
        self.service_fee_amount_host_cents = service_fee_calculator.service_fee_host.try(:cents)
      else
        # This feels a bit hax, but the this is a specific edge case where we don't
        # apply a service fee to manual payments at this stage. However, we still
        # need to calculate and present the service fee as the payment type for
        # supported listings is not confirmed until the executes the reservation.
        self.service_fee_amount_guest_cents = 0
        self.service_fee_amount_host_cents = 0
      end
    end

    def set_currency
      self.currency ||= listing.try(:currency)
    end

    def auto_confirm_reservation
      confirm! unless listing.confirm_reservations?
    end

    def create_scheduled_expiry_task
      Delayed::Job.enqueue Delayed::PerformableMethod.new(self, :should_expire!, nil), run_at: expiry_time
    end

    def attempt_payment_capture
      return if manual_payment? || free? || paid?

      # Generates a ReservationCharge, which is a record of the charge incurred
      # by the user for the reservation (or a part of it), including the
      # gross amount and service fee components.
      #
      # NB: A future story is to separate out extended reservation payments
      #     across multiple payment dates, in which case a Reservation would
      #     have more than one ReservationCharge.
      charge = reservation_charges.create!(
        subtotal_amount: subtotal_amount,
        service_fee_amount_guest: service_fee_amount_guest,
        service_fee_amount_host: service_fee_amount_host
      )

      self.payment_status = if charge.paid?
        PAYMENT_STATUSES[:paid]
      else
        PAYMENT_STATUSES[:failed]
      end
      save!
    end

    def attempt_payment_refund(counter = 0)
      return if !(credit_card_payment? && paid?)
      reservation_charge = reservation_charges.paid.first
      if reservation_charge.nil?
        BackgroundIssueLogger.log_issue("[reservation refund] Unexpected state", "support@desksnear.me", "Reservation id: #{self.id}. It's marked as paid via credit card but reservation_charge has not been created.")
      else
        counter = counter + 1
        if reservation_charge.refund
          self.update_attribute(:payment_status, PAYMENT_STATUSES[:refunded])
        elsif counter < 3
          ReservationRefundJob.perform_later(Time.zone.now + (counter * 6).hours, self.id, counter)
        else
          BackgroundIssueLogger.log_issue("[reservation refund] Refund 3 times failed", "support@desksnear.me", "Reservation id: #{self.id}. We did not manage to automatically refund payment")
        end
      end
      true
    end

    def schedule_refund(transition, counter = 0, run_at = Time.zone.now)
      ReservationRefundJob.perform_later(run_at, self.id, counter)
    end

    def validate_all_dates_available
      invalid_dates = periods.reject(&:bookable?)
      if invalid_dates.any?
        errors.add(:base, "Unfortunately the following bookings are no longer available: #{invalid_dates.map(&:as_formatted_string).join(', ')}")
      end
    end

    def validate_booking_selection
      unless price_calculator.valid?
        errors.add(:base, "Booking selection does not meet requirements. A minimum of #{listing.minimum_booking_days} consecutive bookable days are required.")
      end
    end

end
