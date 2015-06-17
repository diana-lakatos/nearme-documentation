class PaymentGateway::OgonePaymentGateway < PaymentGateway
  include PaymentGateway::ActiveMerchantGateway

  def self.settings
    {
      login: "",
      user: "",
      password: ""
    }
  end

  def self.active_merchant_class
    ActiveMerchant::Billing::OgoneGateway
  end

  def supported_currencies
    ["EUR"]
  end
end

