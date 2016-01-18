class PaymentGateway::StripePaymentGateway < PaymentGateway
  include PaymentGateway::ActiveMerchantGateway

  supported :multiple_currency, :recurring_payment, :credit_card_payment, :partial_refunds

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

  def self.supported_countries
    ["AU", "DK", "FI", "IE", 'NO', 'SE', "US", "GB", "CA"]
  end

  def supported_currencies
    ["AUD", "CAD", "USD", "DKK", "NOK", "SEK", "EUR", "GBP"]
  end

  def gateway
    @gateway ||= ActiveMerchant::Billing::StripeCustomGateway.new(settings)
  end
end

