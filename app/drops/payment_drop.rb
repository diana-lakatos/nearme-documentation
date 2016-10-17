class PaymentDrop < BaseDrop

  # @return [Payment]
  attr_reader :payment

  # @!method id
  #   @return [Integer] numeric identifier for the payment
  # @!method billing_authorizations
  #   Billing authorizations for this payment
  #   @return (see Payment#billing_authorizations)
  # @!method successful_billing_authorization
  #   @return [BillingAuthorization] successful billing authorization for this payment
  # @!method successful_charge
  #   @return [Charge] successful charge object for this payment
  # @!method test_mode?
  #   @return (see Payment#test_mode?)
  # @!method active_merchant_payment?
  #   @return (see Payment#active_merchant_payment?)
  # @!method payable
  #   @return [Order, Object] the associated object for this payment (mostly order objects)
  # @!method currency
  #   Currency for this payment
  #   @return (see Payment#currency)
  # @!method total_amount
  #   @return [Money] total amount for this order
  # @!method created_at
  #   @return [ActiveSupport::TimeWithZone] time when the payment was initiated
  # @!method amount
  #   Alias for total_amount
  #   @return (see Payment#amount)
  # @!method pending?
  #   @return [Boolean] whether the payment is in the pending state
  # @!method voided?
  #   @return [Boolean] whether the payment is in the voided state
  # @todo Investigate missing sum
  delegate :id, :billing_authorizations, :successful_billing_authorization,
           :successful_charge, :test_mode?, :active_merchant_payment?, :payable,
           :currency, :total_amount, :created_at, :sum, :amount, :pending?, :voided?,
           to: :payment

  def initialize(payment)
    @payment = payment
  end

end
