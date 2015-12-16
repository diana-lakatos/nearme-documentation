class RecurringBookingPeriod < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  has_many :payments, as: :payable, dependent: :destroy
  has_many :billing_authorizations, as: :reference
  has_one :billing_authorization, -> { where(success: true) }, as: :reference

  belongs_to :recurring_booking
  belongs_to :credit_card
  delegate :payment_gateway, :company, :company_id, :user, :owner, to: :recurring_booking

  monetize :total_amount_cents, with_model_currency: :currency
  monetize :subtotal_amount_cents, with_model_currency: :currency
  monetize :service_fee_amount_guest_cents, with_model_currency: :currency
  monetize :service_fee_amount_host_cents, with_model_currency: :currency

  def generate_payment!
    payment = payments.create!(
      subtotal_amount: subtotal_amount,
      service_fee_amount_guest: service_fee_amount_guest,
      service_fee_amount_host: service_fee_amount_host,
    )
    if payment.paid?
      self.paid_at = Time.zone.now
      # if we end up doing something in wrong order, we want to have the maximum period_end_date which was paid.
      # so if we pay for December, November and October, we want paid_until to be 31st of December
      recurring_booking.update_attribute(:paid_until, period_end_date) unless recurring_booking.paid_until.present? && recurring_booking.paid_until > period_end_date
    else
      recurring_booking.overdue
    end
    save!
    payment
  end

  def total_amount_cents
    subtotal_amount_cents + service_fee_amount_guest_cents
  end

  def monetized_total_amount
    subtotal_amount + service_fee_amount_guest
  end

end

