class PaymentGateway::SpreedlyPaymentGateway < PaymentGateway
  include PaymentGateway::ActiveMerchantGateway

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

  def support_any_currency!
    true
  end
end

