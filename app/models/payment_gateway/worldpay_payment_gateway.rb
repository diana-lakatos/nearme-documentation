class PaymentGateway::WorldpayPaymentGateway < PaymentGateway
  include PaymentGateway::ActiveMerchantGateway

  supported :any_currency, :credit_card_payment, :multiple_currency
  def self.settings
    { login: { validate: [:presence] } }
  end

  def self.active_merchant_class
    ActiveMerchant::Billing::WorldpayGateway
  end

  def refund_identification(_charge)
  end
end
