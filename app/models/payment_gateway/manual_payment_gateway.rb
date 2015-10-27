class PaymentGateway::ManualPaymentGateway < PaymentGateway

  supported :multiple_currency, :any_currency, :any_country, :manual_payment, :free_payment

  def self.settings
    {}
  end

  def authorize(authoriazable, options = {})
    PaymentAuthorizer::ManualPaymentAuthorizer.new(self, authoriazable, options).process!
  end

  def self.supported_countries

  end
end
