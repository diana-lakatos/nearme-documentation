class PaymentGateway::StripeConnectPaymentGateway < PaymentGateway

  belongs_to :instance

  supported :immediate_payout, :credit_card_payment, :multiple_currency, :partial_refunds, :recurring_payment

  validate :validate_config_hash

  # def self.supported_countries
  #   %w(AT AU BE CA CH DE DK ES FI FR GB IE IT JP LU MX NL NO SE US)
  # end

  def self.supported_countries
    ["AU", "AT", "BE", "BR", "CA", "DK", "FI", "FR", "DE", "HK", "IE", "IT", "JP", "LU", "MX", "NL", "NZ", "NO", "PT", "SG", "ES", "SE", "CH", "GB", "US"]
  end

  def supported_currencies
    ["AED", "ALL", "ANG", "ARS", "AUD", "AWG", "BBD", "BDT", "BIF", "BMD", "BND", "BOB", "BRL", "BSD", "BWP", "BZD", "CAD", "CHF", "CLP", "CNY", "COP", "CRC", "CVE", "CZK", "DJF", "DKK", "DOP", "DZD", "EGP", "ETB", "EUR", "FJD", "FKP", "GBP", "GIP", "GMD", "GNF", "GTQ", "GYD", "HKD", "HNL", "HRK", "HTG", "HUF", "IDR", "ILS", "INR", "ISK", "JMD", "JPY", "KES", "KHR", "KMF", "KRW", "KYD", "KZT", "LAK", "LBP", "LKR", "LRD", "MAD", "MDL", "MNT", "MOP", "MRO", "MUR", "MVR", "MWK", "MXN", "MYR", "NAD", "NGN", "NIO", "NOK", "NPR", "NZD", "PAB", "PEN", "PGK", "PHP", "PKR", "PLN", "PYG", "QAR", "RUB", "SAR", "SBD", "SCR", "SEK", "SGD", "SHP", "SLL", "SOS", "STD", "SVC", "SZL", "THB", "TOP", "TTD", "TWD", "TZS", "UAH", "UGX", "USD", "UYU", "UZS", "VND", "VUV", "WST", "XAF", "XOF", "XPF", "YER", "ZAR", "AFN", "AMD", "AOA", "AZN", "BAM", "BGN", "CDF", "GEL", "KGS", "LSL", "MGA", "MKD", "MZN", "RON", "RSD", "RWF", "SRD", "TJS", "TRY", "XCD", "ZMW"]
  end

  def self.settings
    { login: '' }
  end

  def settings
    super.merge({environment: test_mode? ? :sandbox : :production, test: test_mode? })
  end

  def config_settings
    {
      transfer_schedule: {
        interval: { valid_values: ['default', 'daily', 'weekly', 'monthly'], data: {'data-interval' => '' }},
        weekly_anchor: { valid_values: Date::DAYNAMES.map(&:downcase), data: {'data-show-if' => 'interval-weekly'} },
        monthly_anchor: { valid_values: (1..31).to_a, data: {'data-show-if' => 'interval-monthly'} },
        delay_days: { valid_values: (1..10).to_a, data: {'data-show-if' => 'interval-daily'} }
      },
    }
  end

  def gateway
    @gateway ||= ActiveMerchant::Billing::StripeConnectPayments.new(settings)
  end

  def parse_webhook(*args)
    gateway.parse_webhook(*args)
  end

  def retrieve_account(*args)
    gateway.retrieve_account(*args)
  end

  def onboard!(*args)
    gateway.onboard!(*args)
  end

  def update_onboard!(*args)
    gateway.update_onboard!(*args)
  end

  def charge(user, amount, currency, payment, token)
    charge_record = super(user, amount.to_i, currency, payment, token)
    if charge_record.try(:success?)
      payment_transfer = payment.company.payment_transfers.build(
        payments: [payment.reload],
        payment_gateway_mode: mode,
        payment_gateway_id: self.id,
        token: charge_record.response.params['transfer']
      )

      payout = payment_transfer.payout_attempts.build({
        amount_cents: payment_transfer.amount.cents,
        currency: payment_transfer.amount.currency.iso_code,
        reference: payment_transfer,
        payment_gateway_mode: mode
      })

      payment_transfer.save!
      payout.payout_pending('')
    end
    charge_record
  end

  def payout(*args)
    raise NotImplementedError.new("#{self.name} does not support classic payout")
  end

  def immediate_payout(company)
    merchant_account(company).present?
  end

  def refund_identification(charge)
    charge.payment.successful_billing_authorization.token
  end

  def validate_config_hash
    intrval = config["transfer_schedule"]["interval"]
    if intrval == 'daily'
      label = I18n.t('simple_form.labels.payment_gateway.config.transfer_schedule.delay_days')
      errors.add(:base, label + ' can\'t be blank.') if config["transfer_schedule"]["delay_days"].blank?
    elsif intrval == 'weekly'
      label = I18n.t('simple_form.labels.payment_gateway.config.transfer_schedule.weekly_anchor')
      errors.add(:base, label + ' can\'t be blank.') if config["transfer_schedule"]["weekly_anchor"].blank?
    elsif intrval == 'monthly'
      label = I18n.t('simple_form.labels.payment_gateway.config.transfer_schedule.monthly_anchor')
      errors.add(:base, label + ' can\'t be blank.') if config["transfer_schedule"]["monthly_anchor"].blank?
    end
  end
end
