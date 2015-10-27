class PaymentGateway::SpreedlyPaymentGateway < PaymentGateway
  include PaymentGateway::ActiveMerchantGateway

  supported :any_currency

  def self.settings
    {
      login: "",
      password: "",
      gateway_token: ""
    }
  end

  def self.active_merchant_class
    ActiveMerchant::Billing::SpreedlyCoreGateway
  end
end

