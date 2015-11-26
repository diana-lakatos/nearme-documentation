class RecurringBooking < ActiveRecord::Base
  class NotFound < ActiveRecord::RecordNotFound; end
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  inherits_columns_from_association([:company_id, :administrator_id, :creator_id], :listing)

  before_create :store_platform_context_detail
  after_create :auto_confirm_reservation

  attr_encrypted :authorization_token, :payment_gateway_class, :key => DesksnearMe::Application.config.secret_token

  has_one :billing_authorization, as: :reference
  belongs_to :instance
  belongs_to :listing, class_name: 'Transactable', foreign_key: 'transactable_id', inverse_of: :recurring_bookings
  delegate :location, to: :listing
  belongs_to :owner, :class_name => "User"
  belongs_to :creator, class_name: "User"
  belongs_to :administrator, class_name: "User"
  belongs_to :company
  belongs_to :platform_context_detail, :polymorphic => true
  belongs_to :payment_gateway
  has_many :recurring_booking_periods, dependent: :destroy
  has_many :user_messages, as: :thread_context

  validates :transactable_id, :interval, :presence => true
  validates :owner_id, presence: true, unless: -> { owner.present? }

  scope :upcoming, lambda { where('end_on > ?', Time.zone.now) }
  scope :not_archived, lambda { without_state(:cancelled_by_guest, :cancelled_by_host, :rejected, :expired).uniq }
  scope :visible, lambda { without_state(:cancelled_by_guest, :cancelled_by_host).upcoming }
  scope :not_rejected_or_cancelled, lambda { without_state(:cancelled_by_guest, :cancelled_by_host, :rejected) }
  scope :cancelled, lambda { with_state(:cancelled_by_guest, :cancelled_by_host) }
  scope :confirmed, lambda { with_state(:confirmed) }
  scope :rejected, lambda { with_state(:rejected) }
  scope :expired, lambda { with_state(:expired) }
  scope :cancelled_or_expired_or_rejected, lambda { with_state(:cancelled_by_guest, :cancelled_by_host, :rejected, :expired) }
  scope :archived, lambda { where('end_on < ? OR state IN (?)', Time.zone.today, ['rejected', 'expired', 'cancelled_by_host', 'cancelled_by_guest']).uniq }

  scope :needs_charge, -> (date) { confirmed.where('next_charge_date <= ?', date) }

  monetize :subtotal_amount_cents, with_model_currency: :currency
  monetize :service_fee_amount_guest_cents, with_model_currency: :currency
  monetize :service_fee_amount_host_cents, with_model_currency: :currency

  delegate :favourable_pricing_rate, :service_fee_guest_percent, :service_fee_host_percent, to: :listing, allow_nil: true

  state_machine :state, initial: :unconfirmed do
    before_transition unconfirmed: :confirmed do |reservation, transaction|
      if reservation.check_overbooking && reservation.errors.empty? && period = reservation.generate_next_period!
        period.generate_payment!
        true
      else
        false
      end
    end
    after_transition [:unconfirmed, :confirmed] => :cancelled_by_guest, do: :cancel
    after_transition confirmed: :cancelled_by_host, do: :cancel
    before_transition unconfirmed: :rejected do |reservation, transition|
      reservation.rejection_reason = transition.args[0]
    end
    after_transition confirmed: :overdued do |reservation, transition|
      WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::PaymentOverdue, self.id)
    end


    event :confirm do
      transition unconfirmed: :confirmed
    end

    event :expire do
      transition unconfirmed: :expired
    end

    event :reject do
      transition unconfirmed: :rejected
    end

    event :host_cancel do
      transition confirmed: :cancelled_by_host
    end

    event :guest_cancel do
      transition [:unconfirmed, :confirmed] => :cancelled_by_guest
    end

    event :overdue do
      transition confirmed: :overdued
    end

    event :reconfirm do
      transition overdued: :confirmed
    end

  end

  def check_overbooking
    if (listing.quantity - listing.recurring_bookings.with_state(:confirmed).count) > 0
      true
    else
      errors.add(:base, I18n.t('recurring_bookings.overbooked'))
      false
    end
  end

  def cancel
    update_attribute :end_on, paid_until
    if cancelled_by_guest?
      WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::GuestCancelled, self.id)
    elsif cancelled_by_host?
      WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::HostCancelled, self.id)
    end
  end

  def auto_confirm_reservation
    confirm! unless listing.confirm_reservations?
  end

  def store_platform_context_detail
    self.platform_context_detail_type = PlatformContext.current.platform_context_detail.class.to_s
    self.platform_context_detail_id = PlatformContext.current.platform_context_detail.id
  end

  def administrator
    super.presence || creator
  end

  def user
    @user ||= owner
  end

  def host
    @host ||= creator
  end

  def archived?
    rejected? || cancelled_by_guest? || cancelled_by_host?
  end

  def charger
    @charger ||= RecurringBooking::RecurringBookingChargerFactory.get_charger(self)
  end

  def charger=(charger)
    @charger = charger
  end

  def to_liquid
    @recurring_booking ||= RecurringBookingDrop.new(self)
  end

  def recalculate_next_charge_date
    RecurringBooking::NextDateFactory.get_calculator(self.interval, self.next_charge_date).next_charge_date
  end

  def amount_calculator
    @amount_calculator ||= RecurringBooking::AmountCalculatorFactory.get_calculator(self)
  end

  def amount_calculator=(calculator)
    @amount_calculator = calculator
  end

  def recalculate_next_charge_date!
    self.update_attribute(:next_charge_date, recalculate_next_charge_date)
  end

  def generate_next_period!
    RecurringBooking.transaction do
      # Most likely next_charge_date would be Date.current, however
      # we do not want to rely on delayed_job being invoked on proper day.
      # If we invoke this job later than we should, we don't want to corrupt dates,
      # this is much more safer
      period_start_date = next_charge_date
      amount_to_charge = amount_calculator.subtotal_amount.cents
      host_service_fee = amount_calculator.host_service_fee.cents
      guest_service_fee = amount_calculator.guest_service_fee.cents
      recalculate_next_charge_date!
      recurring_booking_periods.create!(
        service_fee_amount_guest_cents: guest_service_fee,
        service_fee_amount_host_cents: host_service_fee,
        subtotal_amount_cents: amount_to_charge,
        period_start_date: period_start_date,
        period_end_date: next_charge_date - 1.day,
        credit_card_id: credit_card_id,
        currency: currency
      ).tap do
        # to avoid cache issues if one would like to generate multiple periods in the future
        self.amount_calculator = nil
      end
    end
  end

  def host_service_fee
    service_fee_calculator.service_fee_host
  end

  def guest_service_fee
    service_fee_calculator.service_fee_guest
  end

  def additional_charges_amount
    service_fee_calculator.additional_charges_amount
  end

  def total_amount
    total_amount_calculator.total_amount
  end

  def has_service_fee?
    !guest_service_fee.to_f.zero?
  end

  def service_fee_calculator
    options = {
      guest_fee_percent:  service_fee_guest_percent,
      host_fee_percent:   service_fee_host_percent,
      additional_charges: []
    }
    @service_fee_calculator ||= Payment::ServiceFeeCalculator.new(subtotal_amount, options)
  end

  def total_amount_calculator
    @total_amount_calculator ||= RecurringBooking::SubscriptionPriceCalculator.new(self)
  end

  def weekly?
    interval == 'weekly'
  end

  def expiry_time
    created_at + listing.hours_to_expiration.to_i.hours
  end

end

