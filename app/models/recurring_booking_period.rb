class RecurringBookingPeriod < ActiveRecord::Base

  include Payable
  include Modelable

  belongs_to :recurring_booking

  delegate :payment_gateway, :company, :company_id, :user, :owner, :currency,
    :service_fee_guest_percent, :service_fee_host_percent, :payment_subscription,
    :transactable, :quantity, :price_calculator, :cancellation_policy_hours_for_cancellation,
    :cancellation_policy_penalty_percentage, :action, :host, to: :recurring_booking

  scope :unpaid, -> { where(paid_at: nil) }
  scope :paid, -> { where.not(paid_at: nil) }


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

  def generate_payment!
    payment = build_payment(shared_payment_attributes.merge({
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
    recurring_booking.bump_paid_until_date!
  end
end

