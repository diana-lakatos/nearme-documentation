class PaymentGateway < ActiveRecord::Base
  class PaymentGateway::PaymentAttemptError < StandardError; end
  class PaymentGateway::PaymentRefundError < StandardError; end
  class PaymentGateway::RefundNotSupportedError < StandardError; end
  class PaymentGateway::InvalidStateError < StandardError; end

  self.inheritance_column = :type
  auto_set_platform_context
  scoped_to_platform_context

  serialize :test_settings, Hash
  serialize :live_settings, Hash

  PAYMENT_GATEWAYS = {
    'AuthorizeNet' => PaymentGateway::AuthorizeNetPaymentGateway,
    'Braintree' => PaymentGateway::BraintreePaymentGateway,
    'Braintree Marketplace' => PaymentGateway::BraintreeMarketplacePaymentGateway,
    'Fetch' => PaymentGateway::FetchPaymentGateway,
    'Ogone' => PaymentGateway::OgonePaymentGateway,
    'Paypal' => PaymentGateway::PaypalPaymentGateway,
    'Paystation' => PaymentGateway::PaystationPaymentGateway,
    'SagePay' => PaymentGateway::SagePayPaymentGateway,
    'Spreedly' => PaymentGateway::SpreedlyPaymentGateway,
    'Stripe' => PaymentGateway::StripePaymentGateway,
    'Worldpay' => PaymentGateway::WorldpayPaymentGateway,
  }.freeze

  attr_encrypted :test_settings, :live_settings, key: DesksnearMe::Application.config.secret_token, marshal: true

  belongs_to :instance
  belongs_to :payment_gateway

  has_many :country_payment_gateways, dependent: :destroy
  has_many :charges
  has_many :refunds
  has_many :billing_authorizations
  has_many :payouts
  has_many :instance_clients
  has_many :credit_cards
  has_many :merchant_accounts

  attr_accessor :country
  after_save :set_country_config

  def self.supported_countries
    raise NotImplementedError.new("#{self.name} has not implemented self.supported_countries")
  end

  def self.find_or_initialize_by_gateway_name(gateway_name)
    PaymentGateway.where(type: PaymentGateway::PAYMENT_GATEWAYS[gateway_name].to_s).first || PaymentGateway::PAYMENT_GATEWAYS[gateway_name].new
  end

  def self.find_or_initialize_by_type(type)
    PaymentGateway.where(type: type.to_s).first || PaymentGateway::PAYMENT_GATEWAYS.values.find { |value| value.to_s == type }.new
  end

  def name
    @name ||= PaymentGateway::PAYMENT_GATEWAYS.key(self.class)
  end

  def self.countries
    @@countries ||= PAYMENT_GATEWAYS.map { |key, payment_gateway_class| payment_gateway_class.supported_countries }.flatten.uniq.freeze
  end

  def self.supported_at(alpha2_country_code)
    @@payment_gateways_at_country ||= {}
    @@payment_gateways_at_country[alpha2_country_code] ||= PAYMENT_GATEWAYS.select { |key, payment_gateway_class| payment_gateway_class.supported_countries.include?(alpha2_country_code) }.keys.freeze
  end

  def self.settings
    raise NotImplementedError.new("#{self.name} settings not implemented")
  end

  def self.active_merchant_class
    raise NotImplementedError.new("#{self.name} active_merchant_class not implemented")
  end

  def gateway
    raise NotImplementedError
  end

  def set_country_config
    if country.present?
      country_payment_gateway = self.instance.country_payment_gateways.where(country_alpha2_code: country).first_or_initialize
      country_payment_gateway.payment_gateway_id = self.id
      country_payment_gateway.save!
    end
  end

  def settings
    test_mode? ? test_settings : live_settings
  end

  def test_mode?
    @test_mode.nil? ? instance.test_mode? : @test_mode
  end

  def mode
    test_mode? ? 'test' : 'live'
  end

  def force_mode(mode)
    @test_mode = (mode == 'live' ? false : true)
  end

  def authorize(amount, currency, credit_card, options = {})
    options = options.merge(custom_authorize_options).merge({currency: currency, merchant_account: merchant_account(options[:company])})
    response = gateway.authorize(amount, credit_card, options.with_indifferent_access)
    if response.success?
      return {
        token: response.authorization,
      }
    else
      return {
        error: response.message
      }
    end
  end

  def charge(user, amount, currency, payment, token)
    @charge = charges.create(
      amount: amount,
      payment: payment,
      currency: currency,
      user_id: user.id,
      payment_gateway_mode: mode
    )

    begin
      options = custom_capture_options.merge(currency: currency)
      response = gateway.capture(amount, token, options.with_indifferent_access)

      response.success? ? charge_successful(response) : charge_failed(response)
      @charge
    rescue => e
      raise PaymentGateway::PaymentAttemptError, e
    end
  end

  def void(billing_authorization)
    force_mode(billing_authorization.payment_gateway_mode)
    gateway.void(billing_authorization.token)
  end

  def refund(amount, currency, payment, charge)
    force_mode(charge.payment_gateway_mode)
    @refund = refunds.create(
      amount: amount,
      currency: currency,
      payment: payment,
      payment_gateway_mode: mode
    )

    raise PaymentGateway::RefundNotSupportedError, "Refund isn't supported or is not implemented. Please refund this user directly on your gateway account." if !defined?(refund_identification)

    begin
      options = custom_refund_options.merge(currency: currency)
      response = gateway.refund(amount, refund_identification(charge), options.with_indifferent_access)
      response.success? ? refund_successful(response) : refund_failed(response)
      @refund
    rescue => e
      raise PaymentGateway::PaymentRefundError, e
    end
  end

  def store_credit_card(client, credit_card)
    return nil unless support_recurring_payment?

    @instance_client = self.instance_clients.where(client: client).first_or_initialize
    options = { email: client.email, default_card: true, customer: @instance_client.customer_id }
    response = gateway.store(credit_card, options)
    @instance_client.response ||= response.to_yaml
    @instance_client.save!
    @credit_card = credit_cards.where(instance_client: @instance_client).first_or_initialize
    @credit_card.response = response.to_yaml
    @credit_card.save!
    @credit_card.id
  end

  def supports_currency?(currency)
    return true if defined? self.support_any_currency!
    self.supported_currencies.include?(currency)
  end

  def support_recurring_payment?
    false
  end

  # Set to true if payment gateway requires redirect to external page
  def remote?
    return false
  end

  # Set to true if payment gateway supports multiple payment channels like CC and PayPal
  def nonce_payment?
    return false
  end

  def requires_company_onboarding?
    false
  end

  def client_token
    nil
  end

  def payout(company, payout_details)
    force_mode(payout_details[:payment_gateway_mode])
    merchant_account = merchant_account(company)
      if merchant_account
        amount, reference = payout_details[:amount], payout_details[:reference]
        @payout = payouts.create(
          amount: amount.cents,
          currency: amount.currency.iso_code,
          reference: reference,
          payment_gateway_mode: mode
        )
        process_payout(merchant_account, amount)
        @payout
      else
        OpenStruct.new(success: false)
      end
  end

  def immediate_payout(company)
    false
  end

  def supports_payout?
    false
  end

  def onboard!(*args)
    raise NotImplementedError
  end

  protected

  def merchant_account(company)
    return nil if company.nil?
    company.merchant_accounts.where(payment_gateway: self).where.not(state: 'failed').first
  end

  # Callback invoked by processor when charge was successful
  def charge_successful(response)
    @charge.charge_successful(response)
  end

  # Callback invoked by processor when charge failed
  def charge_failed(response)
    @charge.charge_failed(response)
  end

  # Callback invoked by processor when refund was successful
  def refund_successful(response)
    @refund.refund_successful(response)
  end

  # Callback invoked by processor when refund failed
  def refund_failed(response)
    @refund.refund_failed(response)
  end

  def custom_authorize_options
    {}
  end

  def custom_capture_options
    {}
  end

  def custom_refund_options
    {}
  end

  # Callback invoked by processor when payout was successful
  def payout_successful(response)
    @payout.payout_successful(response)
  end

  # Callback invoked by processor when payout failed
  def payout_failed(response)
    @payout.payout_failed(response)
  end

  # Callback invoked by processor when payout is pending
  def payout_pending(response)
    @payout.payout_pending(response)
  end

end

