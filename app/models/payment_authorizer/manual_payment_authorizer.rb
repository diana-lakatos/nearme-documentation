class PaymentAuthorizer::ManualPaymentAuthorizer < PaymentAuthorizer
  def process!
    @authorizable.payment.mark_as_authorized!
    @authorizable.payment.mark_as_paid! if @authorizable.is_free?
    true
  end
end
