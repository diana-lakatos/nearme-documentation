class PaymentGateway::OgonePaymentGateway < PaymentGateway
  include PaymentGateway::ActiveMerchantGateway

  def self.settings
    {
      login: { validate: [:presence] },
      user: { validate: [:presence] },
      password: { validate: [:presence] }
    }
  end

  def self.active_merchant_class
    ActiveMerchant::Billing::OgoneGateway
  end

  def supported_currencies
    ["EUR"]
  end
end

