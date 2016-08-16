class PaymentDrop < BaseDrop

  attr_reader :payment

  delegate :id, :billing_authorizations, :successful_billing_authorization,
    :successful_charge, :test_mode?, :active_merchant_payment?, :payable,
    :currency, :total_amount, :created_at, :sum, :amount,
    to: :payment

  def initialize(payment)
    @payment = payment
  end

end
