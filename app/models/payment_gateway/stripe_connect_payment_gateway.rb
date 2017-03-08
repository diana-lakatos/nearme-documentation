# frozen_string_literal: true
class PaymentGateway::StripeConnectPaymentGateway < PaymentGateway
  include PaymentGateways::StripeCommon

  belongs_to :instance
  has_many :webhooks, class_name: 'Webhook::StripeWebhook', foreign_key: 'payment_gateway_id'

  supported :immediate_payout, :ach_payment, :credit_card_payment, :multiple_currency, :partial_refunds, :payment_source_store

  delegate :parse_webhook, :retrieve_account, :onboard!, :update_onboard!, :find_transfer_transactions,
           :find_payment, :find_balance, :country_spec, :create_customer, :find_customer, to: :gateway

  validate :validate_config_hash

  # def self.supported_countries
  #   %w(AT AU BE CA CH DE DK ES FI FR GB IE IT JP LU MX NL NO SE US)
  # end

  def self.supported_countries
    %w(AU AT BE BR CA DK FI FR DE HK IE IT JP LU MX NL NZ NO PT SG ES SE CH GB US)
  end

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

  def self.settings
    {
      login: { validate: [:presence], label:  "#{test_mode? ? 'Test' : 'Live'} Secret Key" },
      publishable_key: { validate: [:presence_if_direct], label: "#{test_mode? ? 'Test' : 'Live'} Publishable Key" }
    }
  end

  def settings
    super.merge(environment: test_mode? ? :sandbox : :production, test: test_mode?)
  end

  def config_settings
    {
      settings: {
        charge_type: { valid_values: %w(platform direct), data: {} }
      },
      transfer_schedule: {
        interval: { valid_values: %w(default daily weekly monthly), data: { 'data-interval' => '' } },
        weekly_anchor: { valid_values: Date::DAYNAMES.map(&:downcase), data: { 'data-show-if' => 'interval-weekly' } },
        monthly_anchor: { valid_values: (1..31).to_a, data: { 'data-show-if' => 'interval-monthly' } },
        delay_days: { valid_values: (1..10).to_a, data: { 'data-show-if' => 'interval-daily' } }
      }
    }
  end

  def transfer_schedule
    (config[:transfer_schedule] || {}).select do |key, _|
      ['interval', transfer_anchor].include?(key)
    end
  end

  def direct_charge?
    return false if config['settings'].blank?
    config['settings']['charge_type'] == 'direct'
  end

  def gateway
    @gateway ||= ActiveMerchant::Billing::StripeConnectPayments.new(settings)
  end

  def custom_options
  end

  def process_payout(_merchant_account, _amount, _payment_transfer)
    # TODO: integrate Stripe Transfer API for manual transfer_schedule

    payout_pending(@pay_response)
  end

  def immediate_payout(company)
    merchant_account(company).present?
  end

  def refund_identification(charge)
    charge.payment.external_id
  end

  def validate_config_hash
    if transfer_interval == 'daily'
      label = I18n.t('simple_form.labels.payment_gateway.config.transfer_schedule.delay_days')
      errors.add(:base, label + ' can\'t be blank.') if config['transfer_schedule']['delay_days'].blank?
    elsif transfer_interval == 'weekly'
      label = I18n.t('simple_form.labels.payment_gateway.config.transfer_schedule.weekly_anchor')
      errors.add(:base, label + ' can\'t be blank.') if config['transfer_schedule']['weekly_anchor'].blank?
    elsif transfer_interval == 'monthly'
      label = I18n.t('simple_form.labels.payment_gateway.config.transfer_schedule.monthly_anchor')
      errors.add(:base, label + ' can\'t be blank.') if config['transfer_schedule']['monthly_anchor'].blank?
    end
  end

  def transfer_interval
    @transfer_interval ||= config['transfer_schedule'] && config['transfer_schedule']['interval']
  end

  def transfer_anchor
    return 'delay_days' if 'daily' == transfer_interval

    transfer_interval + '_anchor'
  end
end
