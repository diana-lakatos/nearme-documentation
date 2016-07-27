class PaymentDrop < BaseDrop

  attr_reader :payment

  delegate :billing_authorizations, :successful_billing_authorization,
    :successful_charge, :test_mode?, :active_merchant_payment?, to: :payment

  def initialize(payment)
    @payment = payment
  end

end
