require 'braintree'

class PaymentGateway::BraintreePaymentGateway < PaymentGateway
  include PaymentGateway::ActiveMerchantGateway

  MAX_REFUND_ATTEMPTS = 10

  supported :company_onboarding, :recurring_payment, :nonce_payment,
            :credit_card_payment, :partial_refunds, :multiple_currency

  delegate :verify_webhook, :parse_webhook, :find_payment, :find_merchant, :onboard!, :update_onboard!,
           :client_token, :payment_settled?, to: :gateway

  def self.supported_countries
    ['US']
  end

  def self.settings
    {
      merchant_id: { validate: [:presence] },
      public_key: { validate: [:presence] },
      private_key: { validate: [:presence] }
    }
  end

  def self.active_merchant_class
    ActiveMerchant::Billing::BraintreeCustomGateway
  end

  def max_refund_attempts
    MAX_REFUND_ATTEMPTS
  end

  def settings
    super.merge(environment: test_mode? ? :sandbox : :production)
  end

  def supported_currencies
    %w(AED ALL AMD ANG AOA ARS AUD AWG AZN BAM BBD BDT BGN BHD BIF BMD BND BOB BRL BSD BWP BYR BZD CAD CHF CLP CNY COP CRC CVE CZK DJF DKK DOP DZD EEK EGP ERN ETB EUR FJD FKP GBP GEL GHS GIP GMD GNF GTQ GYD HKD HNL HRK HTG HUF IDR ILS INR IRR ISK JMD JOD JPY KES KGS KHR KMF KPW KRW KYD KZT LAK LBP LKR LRD LSL LTL LVL MAD MDL MKD MMK MNT MOP MUR MVR MWK MXN MYR NAD NGN NIO NOK NPR NZD PAB PEN PGK PHP PKR PLN PYG QAR RON RSD RUB RWF SAR SBD SCR SEK SGD SHP SKK SLL SOS STD SVC SYP SZL THB TOP TRY TTD TWD TZS UAH UGX USD UYU UZS VEF VND VUV WST XAF XCD XOF XPF YER ZAR ZMK ZWD)
  end

  def refund_identification(charge)
    charge.payment.authorization_token
  end
end
