# frozen_string_literal: true
class PaymentGateway::StripePaymentGateway < PaymentGateway
  API_VERSION = '2015-04-07'

  supported :multiple_currency, :recurring_payment, :credit_card_payment, :partial_refunds, :any_country

  delegate :find_payment, to: :gateway

  def self.settings
    {
      login: { validate: [:presence], label:  "#{test_mode? ? 'Test' : 'Live'} Secret Key" },
      publishable_key: { validate: [], label: "#{test_mode? ? 'Test' : 'Live'} Publishable Key" }
    }
  end

  def settings
    super.merge(environment: test_mode? ? :sandbox : :production, test: test_mode?)
  end

  def self.active_merchant_class
    ActiveMerchant::Billing::StripeGateway
  end

  def refund_identification(charge)
    charge.response.params['id']
  end

  def credit_card_token_column
    'stripe_id'
  end

  # def self.supported_countries
  # ["AU", "AT", "BE", "BR", "CA", "DK", "FI", "FR", "DE", "HK", "IE", "IT", "JP", "LU", "MX", "NL", "NZ", "NO", "PT", "SG", "ES", "SE", "CH", "GB", "US"]
  # end

  def supported_currencies
    %w(
      AED ALL ANG ARS AUD AWG BBD BDT BIF BMD BND BOB BRL BSD BWP BZD CAD CHF CLP CNY COP CRC CVE
      CZK DJF DKK DOP DZD EGP ETB EUR FJD FKP GBP GIP GMD GNF GTQ GYD HKD HNL HRK HTG HUF IDR ILS
      INR ISK JMD JPY KES KHR KMF KRW KYD KZT LAK LBP LKR LRD MAD MDL MNT MOP MRO MUR MVR MWK MXN
      MYR NAD NGN NIO NOK NPR NZD PAB PEN PGK PHP PKR PLN PYG QAR RUB SAR SBD SCR SEK SGD SHP SLL
      SOS STD SVC SZL THB TOP TTD TWD TZS UAH UGX USD UYU UZS VND VUV WST XAF XOF XPF YER ZAR AFN
      AMD AOA AZN BAM BGN CDF GEL KGS LSL MGA MKD MZN RON RSD RWF SRD TJS TRY XCD ZMW
    )
  end

  def gateway
    @gateway ||= ActiveMerchant::Billing::StripeCustomGateway.new(settings)
  end
end
