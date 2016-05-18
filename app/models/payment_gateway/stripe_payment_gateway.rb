class PaymentGateway::StripePaymentGateway < PaymentGateway
  supported :multiple_currency, :recurring_payment, :credit_card_payment, :partial_refunds

  def self.settings
    { login: { validate: [:presence] } }
  end

  def settings
    super.merge({environment: test_mode? ? :sandbox : :production, test: test_mode? })
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
    ["AU", "AT", "BE", "BR", "CA", "DK", "FI", "FR", "DE", "HK", "IE", "IT", "JP", "LU", "MX", "NL", "NZ", "NO", "PT", "SG", "ES", "SE", "CH", "GB", "US"]
  end

  def supported_currencies
    ["AUD", "CAD", "USD", "DKK", "NOK", "SEK", "EUR", "GBP", "ILS"]
  end

  def gateway
    @gateway ||= ActiveMerchant::Billing::StripeCustomGateway.new(settings)
  end
end

