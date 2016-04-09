class RecurringBookingPeriod < ActiveRecord::Base

  include Chargeable

  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  has_many :additional_charges, as: :target
  has_many :billing_authorizations, as: :reference
  has_many :payments, as: :payable, dependent: :destroy
  has_one :billing_authorization, -> { where(success: true) }, as: :reference

  belongs_to :recurring_booking
  belongs_to :credit_card, -> { with_deleted }

  delegate :payment_gateway, :company, :company_id, :user, :owner, :currency,
    :service_fee_guest_percent, :service_fee_host_percent, :payment_subscription, to: :recurring_booking

  scope :unpaid, -> { where(paid_at: nil) }

  def generate_payment!
    payment = payments.build(
      company: company,
      subtotal_amount: subtotal_amount,
      service_fee_amount_guest: service_fee_amount_guest,
      service_fee_amount_host: service_fee_amount_host,
      credit_card: payment_subscription.credit_card,
      payment_method: payment_subscription.payment_method,
      currency: currency
    )

    payment.authorize && payment.capture!
    payment.save!

    if payment.paid?
      mark_recurring_booking_as_paid!
    else
      recurring_booking.overdue
    end
    save!
    payment
  end

  def update_payment
    # we have unique index so there can be only one payment
    payment = payments.unapid.last
    payment.update_attribute(:credit_card_id, payment_subscription.credit_card_id)
    payment.authorize && payment.capture!
    if payment.paid?
      mark_recurring_booking_as_paid!
    end
    save!
    payment
  end

  def mark_recurring_booking_as_paid!
    self.paid_at = Time.zone.now
    # if we end up doing something in wrong order, we want to have the maximum period_end_date which was paid.
    # so if we pay for December, November and October, we want paid_until to be 31st of December
    recurring_booking.update_attribute(:paid_until, period_end_date) unless recurring_booking.paid_until.present? && recurring_booking.paid_until > period_end_date
  end

  def fees_persisted?
    persisted?
  end

  def tax_amount_cents
    0
  end

  def shipping_amount_cents
    0
  end
end

