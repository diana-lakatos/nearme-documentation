class PaymentGateway::AuthorizeNetPaymentGateway < PaymentGateway
  include PaymentGateway::ActiveMerchantGateway

  def self.settings
    {
      login: "",
      password: ""
    }
  end

  def self.active_merchant_class
    ActiveMerchant::Billing::AuthorizeNetGateway
  end

  def supported_currencies
    ["USD", "CAD"]
  end

end

