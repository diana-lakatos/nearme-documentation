class PaymentGateway::SagePayPaymentGateway < PaymentGateway
  include PaymentGateway::ActiveMerchantGateway

  def self.settings
    { login: { validate: [:presence] } }
  end

  def supported_currencies
    %w(GBP EUR)
  end

  def self.active_merchant_class
    ActiveMerchant::Billing::SagePayGateway
  end

  def refund_identification(_charge)
  end
end
