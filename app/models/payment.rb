class Payment < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  inherits_columns_from_association([:company_id], :payable)

  attr_accessor :payment_response_params

  # === Associations

  belongs_to :company, -> { with_deleted }
  belongs_to :instance
  belongs_to :payment_transfer
  # Payable association connects Payment with Reservation and Spree::Order
  belongs_to :payable, polymorphic: true

  has_many :charges, dependent: :destroy
  has_many :refunds

  # === Scopes
  # These payments have been attempted but failed during the charge attempt.
  # We can inspect the charges to see what the failure reason was
  # from the gateway response.
  scope :needs_payment_capture, -> {
    where(paid_at: nil).where("#{table_name}.failed_at IS NOT NULL")
  }

  scope :paid, -> {
    where("#{table_name}.paid_at IS NOT NULL")
  }

  scope :refunded, -> {
    where("#{table_name}.refunded_at IS NOT NULL")
  }

  scope :not_refunded, -> {
    where("#{table_name}.refunded_at IS NULL")
  }

  scope :last_x_days, lambda { |days_in_past|
    where('DATE(payments.created_at) >= ? ', days_in_past.days.ago)
  }

  scope :needs_payment_transfer, -> {
    paid.where(payment_transfer_id: nil)
  }

  scope :total_by_currency, -> {
    paid.group('payments.currency').
    select('
        payments.currency,
        SUM(
          payments.subtotal_amount_cents
          + payments.service_fee_amount_guest_cents
        )
           ')
  }

  # === Callbacks
  before_validation :assign_currency
  after_create :capture

  validates :currency, presence: true

  # === Helpers
  monetize :subtotal_amount_cents, with_model_currency: :currency
  monetize :service_fee_amount_guest_cents, with_model_currency: :currency
  monetize :service_fee_amount_host_cents, with_model_currency: :currency
  monetize :total_service_fee_cents, with_model_currency: :currency
  monetize :total_amount_cents, with_model_currency: :currency
  monetize :total_additional_charges_cents, with_model_currency: :currency
  monetize :service_additional_charges_cents, with_model_currency: :currency
  monetize :host_additional_charges_cents, with_model_currency: :currency

  def total_amount_cents
    subtotal_amount.cents + service_fee_amount_guest.cents + total_additional_charges.cents
  end

  def total_additional_charges_cents
    service_additional_charges_cents + host_additional_charges_cents
  end

  def subtotal_amount_cents_after_refund
    result = nil

    if self.payable.respond_to?(:cancelled_by_host?) && self.payable.cancelled_by_host?
      result = 0
    else
      result = subtotal_amount.cents + host_additional_charges.cents - refunds.successful.sum(:amount)
    end

    result
  end

  def final_service_fee_amount_host_cents
    result = self.service_fee_amount_host.cents

    if (self.payable.respond_to?(:cancelled_by_host?) && self.payable.cancelled_by_host?) || (self.payable.respond_to?(:cancelled_by_guest?) && self.payable.cancelled_by_guest?)
      result = 0
    end

    result
  end

  def final_service_fee_amount_guest_cents
    result = self.service_fee_amount_guest.cents + self.service_additional_charges.cents

    if self.payable.respond_to?(:cancelled_by_host?) && self.payable.cancelled_by_host?
      result = 0
    end

    result
  end

  def total_service_fee_cents
    final_service_fee_amount_host_cents + final_service_fee_amount_guest_cents
  end

  def amount
    total_amount
  end

  # Attempt to capture the payment through the billing gateway
  def capture
    return if paid?

    begin
      # Generates a ChargeAttempt with this record as the payable.
      if payable.try(:billing_authorization).nil? && !(payable.try(:remote_payment?) || payable.try(:manual_payment?))
        unless billing_gateway.authorize(payable, { customer: payable.credit_card.instance_client.customer_id, order_id: payable.id })
          raise "Failed authorization of credit card token of InstanceClient(id=#{payable.owner.instance_clients.first.try(:id)}) - #{payable.errors[:ccc].try(:first)}"
        end
      end

      charge = billing_gateway.charge(payable.owner, total_amount.cents, currency, self, payable.billing_authorization.try(:token))
      if charge.success?
        touch(:paid_at)
        if payable.respond_to?(:date)
          ReservationChargeTrackerJob.perform_later(payable.date.end_of_day, payable.id)
        end
        # this works for braintree, might not work for others - to be moved to separate class etc, and ideally somewhere else... hackish hack as a quick win
        update_attribute(:external_transaction_id, payable.try(:billing_authorization).try(:response).try(:authorization))
      else
        touch(:failed_at)
      end
    rescue => e
      # Needs to be retried at a later time...
      touch(:failed_at)
      update_column(:recurring_booking_error, e)
    end

  end

  def payment_gateway_mode
    charges.successful.first.try(:payment_gateway_mode)
  end

  def refund
    return if !paid?
    return if refunded?
    return if amount_to_be_refunded <= 0

    successful_charge = charges.successful.first
    return if successful_charge.nil?
    return if PaymentGateway::BraintreeMarketplacePaymentGateway === billing_gateway

    refund = billing_gateway.refund(amount_to_be_refunded, currency, self, successful_charge)

    if refund.success?
      touch(:refunded_at)
      true
    else
      false
    end
  end

  def amount_to_be_refunded
    if payable.respond_to?(:cancelled_by_guest?) && payable.cancelled_by_guest?
      (subtotal_amount.cents * (1 - self.cancellation_policy_penalty_percentage.to_f/BigDecimal(100))).to_i
    else
      total_amount.cents
    end
  end

  def refunded?
    refunded_at.present?
  end

  def paid?
    paid_at.present?
  end

  def failed?
    failed_at.present?
  end

  private

  def billing_gateway
    @billing_gateway ||= payable.billing_authorization.try(:payment_gateway) || payable.try(:payment_gateway) || instance.payment_gateway(payable.company.iso_country_code, currency)
  end

  def assign_currency
    self.currency ||= payable.currency
  end

end
