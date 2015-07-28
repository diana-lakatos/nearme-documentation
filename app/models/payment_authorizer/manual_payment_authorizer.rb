class PaymentAuthorizer::ManualPaymentAuthorizer < PaymentAuthorizer

  def process!
    @authorizable.create_pending_payment! if @authorizable.instance_of?(Spree::Order)
    true
  end
end