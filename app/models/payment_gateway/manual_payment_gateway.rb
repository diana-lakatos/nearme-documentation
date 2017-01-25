class PaymentGateway::ManualPaymentGateway < PaymentGateway
  supported :multiple_currency, :any_currency, :any_country, :manual_payment, :free_payment

  def self.settings
    {}
  end

  def gateway_authorize(*args)
    OpenStruct.new(success?: true, message: 'Mnaual payment auth', authorization: 'manual')
  end

  def gateway_purchase(*args)
    OpenStruct.new(success?: true, message: 'Mnaual payment auth', authorization: 'manual')
  end

  def self.supported_countries
  end
end
