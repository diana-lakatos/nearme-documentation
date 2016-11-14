class PaymentDrop < BaseDrop

  # @return [PaymentDrop]
  attr_reader :payment

  # @!method id
  #   @return [Integer] numeric identifier for the payment
  # @!method billing_authorizations
  #   @return [Array<BillingAuthorizationDrop>] Billing authorizations for this payment
  # @!method successful_billing_authorization
  #   @return [BillingAuthorizationDrop] successful billing authorization for this payment
  # @!method successful_charge
  #   @return [Charge] successful charge object for this payment
  # @!method test_mode?
  #   @return (see Payment#test_mode?)
  # @!method active_merchant_payment?
  #   @return (see Payment#active_merchant_payment?)
  # @!method payable
  #   @return [OrderDrop, Object] the associated object for this payment (mostly order objects)
  # @!method currency
  #   Currency for this payment
  #   @return (see Payment#currency)
  # @!method total_amount
  #   @return [MoneyDrop] total amount for this order
  # @!method created_at
  #   @return [DateTime] time when the payment was initiated
  # @!method amount
  #   @return [MoneyDrop] Alias for total_amount
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
