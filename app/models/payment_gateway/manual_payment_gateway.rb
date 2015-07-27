class PaymentGateway::ManualPaymentGateway < PaymentGateway
  def authorize(authoriazable, options = {})
    PaymentAuthorizer::ManualPaymentAuthorizer.new(self, authoriazable, options).process!
  end

  def self.supported_countries
    []
  end
end
