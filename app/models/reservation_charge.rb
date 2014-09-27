class ReservationCharge < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  inherits_columns_from_association([:company_id], :reservation)

  # === Associations
  belongs_to :reservation
  has_many :charge_attempts,
    :class_name => 'Charge',
    :as => :reference,
    :dependent => :destroy
  has_many :refunds,
    :as => :reference

  belongs_to :instance
  belongs_to :company

  # === Scopes
  # These payments have been attempted but failed during the charge attempt.
  # We can inspect the charge_attempts to see what the failure reason was
  # from the gateway response.
  scope :needs_payment_capture, -> {
    where(paid_at: nil).where("#{table_name}.failed_at IS NOT NULL")
  }

  scope :paid, -> {
    where("#{table_name}.paid_at IS NOT NULL")
  }

  scope :last_x_days, lambda { |days_in_past|
    where('DATE(reservation_charges.created_at) >= ? ', days_in_past.days.ago)
  }

  scope :needs_payment_transfer, -> {
    paid.where(payment_transfer_id: nil)
  }

  scope :total_by_currency, -> {
    paid.group('reservation_charges.currency').
    select('
        reservation_charges.currency,
        SUM(
          reservation_charges.subtotal_amount_cents
          + reservation_charges.service_fee_amount_guest_cents
        )
           ')
  }

  # === Callbacks
  before_validation :assign_currency
  after_create :capture

  validates :currency, presence: true

  # === Helpers
  monetize :subtotal_amount_cents
  monetize :service_fee_amount_guest_cents
  monetize :service_fee_amount_host_cents
  monetize :total_amount_cents

  def total_amount_cents
    subtotal_amount_cents + service_fee_amount_guest_cents
  end

  def subtotal_amount_cents_after_refund
    subtotal_amount_cents - refunds.successful.sum(&:amount)
  end

  def amount
    total_amount
  end

  # Attempt to capture the payment through the billing gateway
  def capture
    return if paid?

    # Generates a ChargeAttempt with this record as the reference.

    if reservation.billing_authorization.nil? && !reservation.remote_payment?

      response = billing_gateway.authorize(reservation.total_amount_cents, reservation.credit_card.token, { customer: reservation.credit_card.instance_client.customer_id })
      if response[:error].present?
        raise Billing::Gateway::PaymentAttemptError, "Failed authorization of credit card token of InstanceClient(id=#{reservation.owner.instance_clients.first.try(:id)}) - #{response[:error]}"
      else
        reservation.create_billing_authorization(
          token: response[:token],
          payment_gateway_class: billing_gateway.class.name,
          payment_gateway_mode: PlatformContext.current.instance.test_mode? ? "test" : "live"
        )
      end
    end

    begin
      billing_gateway.charge(total_amount_cents, self, reservation.billing_authorization.try(:token))
      touch(:paid_at)

      ReservationChargeTrackerJob.perform_later(reservation.date.end_of_day, reservation.id)
    rescue => e
      # Needs to be retried at a later time...
      touch(:failed_at)
      update_column(:recurring_booking_error, e)
    end

  end

  def refund
    return if !paid?
    return if refunded?
    return if amount_to_be_refunded <= 0

    successful_charge = charge_attempts.successful.first
    return if successful_charge.nil?

    refund = billing_gateway.refund(amount_to_be_refunded, self, successful_charge.response)

    if refund.success?
      touch(:refunded_at)
      true
    else
      false
    end
  end

  def amount_to_be_refunded
    if reservation.cancelled_by_guest?
      (subtotal_amount_cents * (1 - self.cancellation_policy_penalty_percentage.to_f/100.0)).to_i
    else
      total_amount_cents
    end
  end

  def refunded?
    refunded_at.present?
  end

  def paid?
    paid_at.present?
  end

  private

  def billing_gateway
    @billing_gateway ||= if reservation.billing_authorization.try(:payment_gateway_class).present?
                           reservation.billing_authorization.payment_gateway_class.to_s.constantize.new(reservation.owner, instance, currency)
                         else
                           Billing::Gateway::Incoming.new(reservation.owner, instance, currency)
                         end
  end

  def assign_currency
    self.currency ||= reservation.currency
  end

end
