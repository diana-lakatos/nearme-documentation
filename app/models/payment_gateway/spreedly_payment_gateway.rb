class PaymentGateway::SpreedlyPaymentGateway < PaymentGateway
  include PaymentGateway::ActiveMerchantGateway

  supported :any_currency

  def self.settings
    {
      login: { validate: [:presence] },
      password: { validate: [:presence] },
      gateway_token: { validate: [:presence] }
    }
  end

  def self.active_merchant_class
    ActiveMerchant::Billing::SpreedlyCoreGateway
  end
end

