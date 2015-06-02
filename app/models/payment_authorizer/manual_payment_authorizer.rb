class PaymentAuthorizer::ManualPaymentAuthorizer < PaymentAuthorizer

  def process!
    create_success_payment_record if @authorizable.instance_of?(Spree::Order)
    true
  end
end