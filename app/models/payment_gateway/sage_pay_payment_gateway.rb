class PaymentGateway::SagePayPaymentGateway < PaymentGateway
  include PaymentGateway::ActiveMerchantGateway

  def self.settings
    { login: "" }
  end

  def self.active_merchant_class
    ActiveMerchant::Billing::SagePayGateway
  end

  def refund_identification(charge)

  end
end

