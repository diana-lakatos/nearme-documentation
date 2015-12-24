class PaymentAuthorizer::ManualPaymentAuthorizer < PaymentAuthorizer

  def process!
    if @authorizable.instance_of?(Spree::Order)
      @authorizable.create_pending_payment!
    else
      @authorizable.mark_as_authorized!
      @authorizable.mark_as_paid! if @authorizable.is_free?
    end
    true
  end
end
