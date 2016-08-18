class RecurringBookingPeriod < ActiveRecord::Base

  include Payable
  include Modelable

  after_create :send_creation_alert

  belongs_to :recurring_booking, foreign_key: :order_id
  belongs_to :order

  delegate :payment_gateway, :company, :company_id, :user, :owner, :currency,
    :service_fee_guest_percent, :service_fee_host_percent, :payment_subscription,
    :transactable, :quantity, :cancellation_policy_hours_for_cancellation,
    :cancellation_policy_penalty_percentage, :action, :host, :is_free_booking?, to: :order

  scope :unpaid, -> { where(paid_at: nil) }
  scope :paid, -> { where.not(paid_at: nil) }

  state_machine :state, initial: :pending do
    event :approve                  do transition [:rejected, :pending] => :approved; end
    event :reject                   do transition pending: :rejected; end

    after_transition [:rejected, :pending] => :approved, do: :send_approve_alert
    after_transition pending: :rejected, do: :send_reject_alert
  end

  def skip_payment_authorization
    false
  end
  alias :skip_payment_authorization? :skip_payment_authorization

  # TODO unifiy with ReservationPeriod
  def starts_at
    period_start_date
  end

  def ends_at
    period_end_date
  end

  def start_minute
    0
  end

  def set_service_fees
    transactable_line_items.each do |tli|
      tli.attributes = {
        service_fee_guest_percent: action.service_fee_guest_percent,
        service_fee_host_percent: action.service_fee_host_percent,
      }
    end
  end

  def price_calculator
    recurring_booking.amount_calculator
  end

  def charge_and_approve!
    generate_payment!
    paid? ? approve! : false
  end

  def generate_payment!
    return true if paid?

    payment = build_payment(
      shared_payment_attributes.merge({
        credit_card: payment_subscription.credit_card,
        payment_method: payment_subscription.payment_method,
      })
    )

    payment.authorize && payment.capture!
    payment.save!

    if payment.paid?
      self.update_attribute(:paid_at, Time.zone.now)
      mark_recurring_booking_as_paid!
    else
      recurring_booking.overdue
    end

    payment
  end

  def paid?
    is_free_booking? ? true : !!payment.try(:paid?)
  end

  def update_payment
    # we have unique index so there can be only one payment
    payment.update_attribute(:credit_card_id, payment_subscription.credit_card_id)
    payment.authorize && payment.capture!
    if payment.paid?
      self.update_attribute(:paid_at, Time.zone.now)
      mark_recurring_booking_as_paid!
    end
    save!
    payment
  end

  def mark_recurring_booking_as_paid!
    recurring_booking.bump_paid_until_date! if recurring_booking
  end

  def to_liquid
    @booking_period_drop ||= RecurringBookingPeriodDrop.new(self)
  end

  def decorate
    @decorator ||= OrderItemDecorator.new(self)
  end

  private

  def send_creation_alert
    WorkflowStepJob.perform(WorkflowStep::OrderItemWorkflow::Created, self.id)
  end

  def send_approve_alert
    WorkflowStepJob.perform(WorkflowStep::OrderItemWorkflow::Approved, self.id)
  end

  def send_reject_alert
    WorkflowStepJob.perform(WorkflowStep::OrderItemWorkflow::Rejected, self.id)
  end
end

