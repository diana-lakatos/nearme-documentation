class PaymentGateway::StripePaymentGateway < PaymentGateway
  include PaymentGateway::ActiveMerchantGateway

  def self.settings
    { login: "" }
  end

  def self.active_merchant_class
    ActiveMerchant::Billing::StripeGateway
  end

  def refund_identification(charge)
    charge.response.params["id"]
  end

  def credit_card_token_column
    'stripe_id'
  end

  def support_any_currency!
    true
  end

  def supports_recurring_payment?
    true
  end

  def gateway
    ActiveMerchant::Billing::Base.mode = :test if test_mode?
    @gateway ||= ActiveMerchant::Billing::StripeCustomGateway.new(settings)
  end
end

