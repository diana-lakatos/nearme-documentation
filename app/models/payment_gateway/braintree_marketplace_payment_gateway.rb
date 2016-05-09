class PaymentGateway::BraintreeMarketplacePaymentGateway < PaymentGateway

  supported :company_onboarding, :immediate_payout, :credit_card_payment,
    :partial_refunds, :host_subscription, :multiple_currency

  def self.supported_countries
    ['US']
  end

  def self.settings
    {
      merchant_id: { validate: [:presence] },
      public_key: { validate: [:presence] },
      private_key: { validate: [:presence] },
      master_merchant_account_id: { validate: [:presence] }
    }
  end

  def self.payout_supported_countries
    self.supported_countries
  end

  def settings
    super.merge({environment: test_mode? ? :sandbox : :production })
  end

  def gateway
    @gateway ||= ActiveMerchant::Billing::BraintreeMarketplacePayments.new(settings)
  end

  def payment_settled?(token)
    configure_braintree_class
    transaction = Braintree::Transaction.find(token)
    transaction.status == 'settled'
  end

  def verify_webhook(*args)
    gateway.verify(*args)
  end

  def parse_webhook(*args)
    gateway.parse_webhook(*args)
  end

  def find(*args)
    gateway.find(*args)
  end

  def onboard!(*args)
    gateway.onboard!(*args)
  end

  def update_onboard!(*args)
    gateway.update_onboard!(*args)
  end

  def charge(user, amount, currency, payment, token)
    charge_record = super(user, amount, currency, payment, token)
    if charge_record.try(:success?)
      payment_transfer = payment.company.payment_transfers.create!(payments: [payment.reload], payment_gateway_mode: mode, payment_gateway_id: self.id)
      unless payment.payable.billing_authorization.immediate_payout?
        payment_transfer.update_attribute(:transferred_at, nil)
      end
    end
    charge_record
  end

  def payout(*args)
    OpenStruct.new(success: true, success?: true)
  end

  def client_token
    @client_token ||= gateway.client_token
  end

  def refund_identification(charge)
    charge.payment.payable.billing_authorization.token
  end

  def supported_currencies
    [
      "AED", "ALL", "AMD", "ANG", "AOA", "ARS", "AUD", "AWG", "AZN", "BAM", "BBD", "BDT", "BGN", "BHD", "BIF",
      "BMD", "BND", "BOB", "BRL", "BSD", "BWP", "BYR", "BZD", "CAD", "CHF", "CLP", "CNY", "COP", "CRC", "CVE",
      "CZK", "DJF", "DKK", "DOP", "DZD", "EEK", "EGP", "ERN", "ETB", "EUR", "FJD", "FKP", "GBP", "GEL", "GHS",
      "GIP", "GMD", "GNF", "GTQ", "GYD", "HKD", "HNL", "HRK", "HTG", "HUF", "IDR", "ILS", "INR", "IRR", "ISK",
      "JMD", "JOD", "JPY", "KES", "KGS", "KHR", "KMF", "KPW", "KRW", "KYD", "KZT", "LAK", "LBP", "LKR", "LRD",
      "LSL", "LTL", "LVL", "MAD", "MDL", "MKD", "MMK", "MNT", "MOP", "MUR", "MVR", "MWK", "MXN", "MYR", "NAD",
      "NGN", "NIO", "NOK", "NPR", "NZD", "PAB", "PEN", "PGK", "PHP", "PKR", "PLN", "PYG", "QAR", "RON", "RSD",
      "RUB", "RWF", "SAR", "SBD", "SCR", "SEK", "SGD", "SHP", "SKK", "SLL", "SOS", "STD", "SVC", "SYP", "SZL",
      "THB", "TOP", "TRY", "TTD", "TWD", "TZS", "UAH", "UGX", "USD", "UYU", "UZS", "VEF", "VND", "VUV", "WST",
      "XAF", "XCD", "XOF", "XPF", "YER", "ZAR", "ZMK", "ZWD"
    ]
  end


  def immediate_payout(company)
    merchant_account(company).present?
  end

  def supports_immediate_payout?
    true
  end

  def credit_card_payment?
    true
  end

  private

  def configure_braintree_class
    Braintree::Configuration.environment = settings["environment"]
    Braintree::Configuration.merchant_id = settings["merchant_id"]
    Braintree::Configuration.public_key  = settings["public_key"]
    Braintree::Configuration.private_key = settings["private_key"]
  end
end

