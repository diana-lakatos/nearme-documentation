# frozen_string_literal: true
class RecurringBooking < Order
  include Bookable
  include Categorizable

  delegate :favourable_pricing_rate, to: :action, allow_nil: true
  delegate :action, to: :transactable_pricing

  has_one :old, class_name: 'OldRecurringBooking', foreign_key: 'order_id'

  # Note: additional_charges are not yet implemented for RecurringBooking
  # Following line is added only for the purpouse of including Chargebale model

  has_many :recurring_booking_periods, dependent: :destroy
  has_many :periods, class_name: 'RecurringBookingPeriod', dependent: :destroy

  scope :upcoming, -> { where('ends_at > ?', Time.zone.now) }
  scope :archived, -> { where('ends_at < ? OR state IN (?)', Time.zone.now, %w(rejected expired cancelled_by_host cancelled_by_guest)).uniq }
  scope :not_archived, -> { without_state(:cancelled_by_guest, :cancelled_by_host, :rejected, :expired).uniq }
  scope :needs_charge, -> (date) { with_state(:confirmed, :overdued).where('next_charge_date <= ?', date) }

  before_validation :set_dates, on: :create

  validates :transactable_id, presence: true
  validates :owner_id, presence: true, unless: -> { owner.present? }

  state_machine :state, initial: :inactive do
    before_transition unconfirmed: :confirmed do |recurring_booking, _transaction|
      if recurring_booking.check_overbooking && recurring_booking.errors.empty? && period = recurring_booking.generate_next_period!
        period.generate_payment!
        true
      else
        false
      end
    end
    after_transition [:unconfirmed, :confirmed] => :cancelled_by_guest, do: :cancel
    after_transition confirmed: :cancelled_by_host, do: :cancel
    before_transition unconfirmed: :rejected do |recurring_booking, transition|
      recurring_booking.rejection_reason = transition.args[0]
    end

    after_transition confirmed: :overdued do |recurring_booking, _transition|
      WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::PaymentOverdue, recurring_booking.id)
    end

    after_transition overdued: :confirmed do |recurring_booking, _transition|
      WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::PaymentInformationUpdated, recurring_booking.id)
    end

    event :expire       do   transition unconfirmed: :expired; end
    event :host_cancel  do   transition all => :cancelled_by_host; end
    event :guest_cancel do   transition [:unconfirmed, :confirmed] => :cancelled_by_guest; end
    event :overdue      do   transition confirmed: :overdued; end
    event :reconfirm    do   transition overdued: :confirmed; end
  end

  def self.workflow_class
    RecurringBooking
  end

  def try_to_activate!
    return true unless inactive? && valid?
    return true if payment_subscription.blank?

    activate! if payment_subscription.credit_card.try(:success?)
  end

  def activate_order!
    schedule_expiry
    auto_confirm_reservation
  end

  def set_dates
    self.starts_at = @dates ? Date.parse(@dates) : Date.current
    self.next_charge_date = start_on
  end

  def billing_address_required?
    false
  end

  def shipping_address_required?
    false
  end

  # @return [FalseClass] false
  def with_delivery?
    false
  end

  # Temporary work around, change when there's time for it
  def start_on
    starts_at.try(:utc).try(:to_date)
  end

  def end_on
    ends_at.try(:to_date)
  end

  def check_overbooking
    if (transactable.quantity - transactable.recurring_bookings.with_state(:confirmed).count) > 0
      true
    else
      errors.add(:base, I18n.t('recurring_bookings.overbooked'))
      false
    end
  end

  def cancel
    update_attribute :ends_at, paid_until
    if cancelled_by_guest?
      WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::EnquirerCancelled, id)
    elsif cancelled_by_host?
      WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::ListerCancelled, id)
    end
  end

  def auto_confirm_reservation
    if transactable.confirm_reservations?
      WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::CreatedWithoutAutoConfirmation, id)
    else
      confirm!
      WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::CreatedWithAutoConfirmation, id)
    end
  end

  def cancelable?
    true
  end

  def client
    user
  end

  def archived?
    rejected? || cancelled_by_guest? || cancelled_by_host?
  end

  def schedule_refund(_transition, _run_at = Time.zone.now)
    true
  end

  def charger
    @charger ||= RecurringBooking::RecurringBookingChargerFactory.get_charger(self)
  end

  attr_writer :charger

  def to_liquid
    @recurring_booking ||= RecurringBookingDrop.new(self)
  end

  def recalculate_next_charge_date
    RecurringBooking::NextDateFactory.get_calculator(transactable_pricing, next_charge_date).next_charge_date
  end

  def amount_calculator
    @amount_calculator ||= RecurringBooking::AmountCalculatorFactory.get_calculator(self)
  end

  attr_writer :amount_calculator

  def recalculate_next_charge_date!
    update_attribute(:next_charge_date, recalculate_next_charge_date)
  end

  def generate_next_period!
    RecurringBooking.transaction do
      # Most likely next_charge_date would be Date.current, however
      # we do not want to rely on delayed_job being invoked on proper day.
      # If we invoke this job later than we should, we don't want to corrupt dates,
      # this is much more safer
      period_start_date = next_charge_date

      recalculate_next_charge_date!

      period = recurring_booking_periods.create!(
        period_start_date: period_start_date,
        period_end_date: next_charge_date - 1.day,
        credit_card_id: payment_subscription.credit_card_id,
        currency: currency,
        order: self
      ).tap do
        # to avoid cache issues if one would like to generate multiple periods in the future
        self.amount_calculator = nil
      end

      period.reload
    end
  end

  def bump_paid_until_date!
    # if someone skips payment for October, but will pay for November, we do not want to set paid_until date to November. We will set it to November after
    # he pays for October.
    update_attribute(:paid_until, recurring_booking_periods.paid.maximum(:period_end_date)) unless recurring_booking_periods.unpaid.count > 0
  end

  def total_amount_calculator
    @total_amount_calculator ||= RecurringBooking::SubscriptionPriceCalculator.new(self)
  end
  alias price_calculator total_amount_calculator

  def monthly?
    transactable_pricing.unit == 'subscription_month'
  end

  def first_transactable_line_item
    transactable_line_items.first
  end

  [:service_fee_guest_percent, :service_fee_host_percent, :minimum_lister_service_fee_cents].each do |method_name|
    define_method method_name do
      first_transactable_line_item.try(method_name) || action.try(method_name)
    end
  end
end
