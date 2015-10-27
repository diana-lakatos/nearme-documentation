class PaymentGateway::PaystationPaymentGateway < PaymentGateway
  include PaymentGateway::ActiveMerchantGateway

  supported  :credit_card_payment

  def self.settings
    {
      paystation_id: "",
      gateway_id: ""
    }
  end

  def self.active_merchant_class
    ActiveMerchant::Billing::PaystationGateway
  end

  def supported_currencies
    ["NZD"]
  end
end

