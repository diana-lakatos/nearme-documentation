class PaymentGateway < ActiveRecord::Base
  include Encryptable
  include Modelable

  class PaymentGateway::PaymentAttemptError < StandardError; end
  class PaymentGateway::PaymentRefundError < StandardError; end
  class PaymentGateway::RefundNotSupportedError < StandardError; end
  class PaymentGateway::InvalidStateError < StandardError; end

  self.inheritance_column = :type

  scope :mode_scope, -> { test_mode? ? where(test_active: true) : where(live_active: true) }
  scope :live, -> { where(live_active: true) }
  scope :payout_type, -> { where(type: PAYOUT_GATEWAYS.values + IMMEDIATE_PAYOUT_GATEWAYS.values) }
  scope :payment_type, -> { where.not(type: PAYOUT_GATEWAYS.values) }
  scope :with_credit_card, -> { joins(:payment_methods).merge(PaymentMethod.active.credit_card) }

  serialize :test_settings, Hash
  serialize :live_settings, Hash
  serialize :config, Hash

  validates_each :test_settings do |payment_gateway, attribute, value|
    validate_settings(payment_gateway, attribute, value)
  end

  validates_each :live_settings do |payment_gateway, attribute, value|
    validate_settings(payment_gateway, attribute, value)
  end

  belongs_to :payment_gateway

  has_many :active_payment_methods, -> (_object) { active.except_free }, class_name: 'PaymentMethod'
  has_many :active_free_payment_methods, -> (_object) { active.free }, class_name: 'PaymentMethod'
  has_many :billing_authorizations
  has_many :credit_cards
  has_many :charges
  has_many :payouts
  has_many :instance_clients, dependent: :destroy
  has_many :merchant_accounts, dependent: :destroy
  has_many :payments
  has_many :payment_transfers
  has_many :payment_gateways_countries, dependent: :destroy
  has_many :payment_countries, through: :payment_gateways_countries, source: 'country'
  has_many :payment_gateways_currencies, dependent: :destroy
  has_many :payment_currencies, through: :payment_gateways_currencies, source: 'currency'
  has_many :payment_methods, dependent: :destroy
  has_many :refunds
  has_many :webhooks, as: :webhookable, dependent: :destroy

  accepts_nested_attributes_for :payment_methods, reject_if: :all_blank

  validates :type, presence: true
  validates :payment_countries, presence: true, if: proc { |p| p.active? }
  validates :payment_currencies, presence: true, if: proc { |p| p.active? }
  validates :payment_methods, presence: true, if: proc { |p| p.active? && !p.supports_payout? }
  validate do
    errors.add(:payment_methods, 'At least one payment method must be selected') if active? && !supports_payout? && !payment_methods.any?(&:active?)
  end

  AUTH_ERROR = 'Payment Gateway authorization error'.freeze
  CAPTURE_ERROR = 'Payment Gateway capture error'.freeze
  VOID_ERROR = 'Payment Gateway void error'.freeze
  REFUND_ERROR = 'Payment Gateway refund error'.freeze
  STORE_ERROR = 'Payment Gateway credit card store error'.freeze
  UNSTORE_ERROR = 'Payment Gateway credit card delete error'.freeze
  PURCHASE_ERROR = 'Payment Gateway purchase error'.freeze

  PAYOUT_GATEWAYS = {
    'PayPal Adpative Payments (Payouts)' => 'PaymentGateway::PaypalAdaptivePaymentGateway'
  }.freeze

  IMMEDIATE_PAYOUT_GATEWAYS = {
    'Braintree Marketplace' => 'PaymentGateway::BraintreeMarketplacePaymentGateway',
    'PayPal Express In Chain Payments' => 'PaymentGateway::PaypalExpressChainPaymentGateway',
    'Stripe Connect' => 'PaymentGateway::StripeConnectPaymentGateway'
  }.freeze

  PAYMENT_GATEWAYS = {
    'AuthorizeNet' => 'PaymentGateway::AuthorizeNetPaymentGateway',
    'Braintree' => 'PaymentGateway::BraintreePaymentGateway',
    'Braintree Marketplace' => 'PaymentGateway::BraintreeMarketplacePaymentGateway',
    'Fetch' => 'PaymentGateway::FetchPaymentGateway',
    'Ogone' => 'PaymentGateway::OgonePaymentGateway',
    'PayPal Payments Pro' => 'PaymentGateway::PaypalPaymentGateway',
    'PayPal Adpative Payments (Payouts)' => 'PaymentGateway::PaypalAdaptivePaymentGateway',
    'PayPal Express' => 'PaymentGateway::PaypalExpressPaymentGateway',
    'PayPal Express In Chain Payments' => 'PaymentGateway::PaypalExpressChainPaymentGateway',
    'Paystation' => 'PaymentGateway::PaystationPaymentGateway',
    'SagePay' => 'PaymentGateway::SagePayPaymentGateway',
    'Spreedly' => 'PaymentGateway::SpreedlyPaymentGateway',
    'Stripe' => 'PaymentGateway::StripePaymentGateway',
    'Stripe Connect' => 'PaymentGateway::StripeConnectPaymentGateway',
    'Worldpay' => 'PaymentGateway::WorldpayPaymentGateway',
    'Offline Payment' => 'PaymentGateway::ManualPaymentGateway'
  }.freeze

  MAX_REFUND_ATTEMPTS = 3

  # supported/unsuppoted class method definition in config/initializers/act_as_supported.rb

  not_implemented :gateway, :parse_webhook, :verify_webhook, :onboard!

  unsupported :payout, :any_country, :any_currency, :paypal_express_payment, :paypal_chain_payments,
              :multiple_currency, :express_checkout_payment, :nonce_payment, :company_onboarding, :remote_paymnt,
              :recurring_payment, :credit_card_payment, :manual_payment, :remote_payment, :free_payment, :immediate_payout, :free_payment,
              :partial_refunds, :refund_from_host, :host_subscription

  attr_encrypted :test_settings, :live_settings, marshal: true

  attr_accessor :country, :subject

  #- CLASS METHODS STARTS HERE

  def self.supported_countries
    raise NotImplementedError, "#{name} has not implemented self.supported_countries"
  end

  def config_settings
    {}
  end

  def documentation_url
    nil
  end

  def active?
    live_active? || test_active?
  end

  def active_in_current_mode?
    test_mode? ? test_active? : live_active?
  end

  def client_token
    nil
  end

  def supported_currencies
    []
  end

  def direct_charge?
    false
  end

  def self.find_or_initialize_by_gateway_name(gateway_name)
    PaymentGateway.where(type: PaymentGateway::PAYMENT_GATEWAYS[gateway_name].to_s).first || PaymentGateway::PAYMENT_GATEWAYS[gateway_name].new
  end

  def self.find_or_initialize_by_type(type)
    PaymentGateway.where(type: type.to_s).first || PaymentGateway::PAYMENT_GATEWAYS.values.find { |value| value.to_s == type }.new
  end

  def self.countries
    @@countries ||= PAYMENT_GATEWAYS.map { |_key, payment_gateway_class| payment_gateway_class.supported_countries }.flatten.uniq.freeze
  end

  def self.supported_at(alpha2_country_code)
    @@payment_gateways_at_country ||= {}
    @@payment_gateways_at_country[alpha2_country_code] ||= PAYMENT_GATEWAYS.select { |_key, payment_gateway_class| payment_gateway_class.supported_countries.include?(alpha2_country_code) }.keys.freeze
  end

  def self.settings
    {}
  end

  def self.active_merchant_class
    raise NotImplementedError, "#{name} active_merchant_class not implemented"
  end

  def self.model_name
    ActiveModel::Name.new(PaymentGateway)
  end

  def self.validate_settings(payment_gateway, attribute, value)
    if payment_gateway.send(attribute.to_s.gsub('settings', 'active?'))
      value.each do |key, value|
        next if payment_gateway.class.settings[key.to_sym].blank? ||
                payment_gateway.class.settings[key.to_sym][:validate].blank?

        payment_gateway.class.settings[key.to_sym][:validate].each do |validation|
          case validation
          when :presence
            payment_gateway.errors.add(attribute, ": #{key.capitalize.gsub('_id', '')} can't be blank!") if value.blank?
          when :presence_if_direct
            if value.blank? && payment_gateway.direct_charge?
              payment_gateway.errors.add(attribute, ": #{key.capitalize.gsub('_id', '')} can't be blank when direct charge enabled!")
            end
          end
        end
      end if value.present?
    end
  end

  #- END CLASS METHODS

  def authorize(payment, options = {})
    force_mode(payment.payment_gateway_mode)
    PaymentAuthorizer.new(self, payment, options).process!
  end

  def editable?
    merchant_accounts.live.active.blank? && payments.live.active.blank?
  end

  def deletable?
    merchant_accounts.live.active.blank? && payments.live.active.blank?
  end

  def can_disable?
    test_mode? || merchant_accounts.live.verified.blank?
  end

  def payout_gateway?
    PAYOUT_GATEWAYS.values.include?(self.class.to_s)
  end

  def name
    @name ||= PaymentGateway::PAYMENT_GATEWAYS.key(self.class.name)
  end

  def host
    port = ':3000'
    "http://#{PlatformContext.current.decorate.host}#{Rails.env.development? ? port : ''}"
  end

  def available_payment_countries
    if supports_any_country?
      Country.all
    else
      Country.where(iso: self.class.supported_countries)
    end
  end

  def available_currencies
    if supports_any_currency?
      Currency.order(:name)
    else
      Currency.where(iso_code: supported_currencies).order(:name)
    end
  end

  def settings
    (test_mode? ? test_settings || {} : live_settings || {}).with_indifferent_access
  end

  def supports_currency?(currency)
    return true if supports_any_currency?
    supported_currencies.include?(currency)
  end

  def configured?(country_alpha2_code)
    settings.present? && payment_countries.where(iso: country_alpha2_code).any?
  end

  def self.test_mode?
    @test_mode.nil? ? PlatformContext.current.try { |c| c.instance.test_mode? } : @test_mode
  end

  def test_mode?
    @test_mode.nil? ? instance.test_mode? : @test_mode
  end

  def type_name
    type.gsub('PaymentGateway', '').sub('::', '').underscore.tr(' ', '_')
  end

  def mode
    test_mode? ? 'test' : 'live'
  end

  def force_mode(mode)
    @test_mode = (mode == 'live' ? false : true)
  end

  def create_token(credit_card, customer_id, merchant_id, mode)
    force_mode(mode)
    gateway.create_token(credit_card, customer_id, merchant_id)
  end

  def charge(user, amount, currency, payment, token)
    force_mode(payment.payment_gateway_mode)

    @payment = payment
    @merchant_account = payment.merchant_account
    @payable = @payment.payable
    @charge = charges.create(
      amount: amount,
      payment: payment,
      currency: currency,
      user_id: user.id,
      payment_gateway_mode: mode
    )

    options = custom_capture_options.merge(currency: currency)
    options.merge!(@merchant_account.custom_options) if @merchant_account

    response = gateway_capture(amount, token, options.with_indifferent_access)
    response.success? ? charge_successful(response) : charge_failed(response)
    @charge
  end

  def gateway_authorize(amount, cc, options)
    gateway.authorize(amount, cc, options)
  rescue => e
    MarketplaceLogger.error(AUTH_ERROR, e.to_s, raise: false)
    OpenStruct.new(success?: false, message: e.to_s)
  end

  def gateway_capture(amount, token, options)
    gateway.capture(amount, token, options)
  rescue => e
    MarketplaceLogger.error(CAPTURE_ERROR, e.to_s, raise: false)
    @payment.update_column(:recurring_booking_error, e) if @payment
    OpenStruct.new(success?: false, message: e.to_s)
  end

  def gateway_purchase(amount, credit_card_or_vault_id, options)
    gateway.purchase(amount, credit_card_or_vault_id, options)
  rescue => e
    MarketplaceLogger.error(PURCHASE_ERROR, e.to_s, raise: false)
    OpenStruct.new(success?: false, message: e.to_s)
  end

  def void(payment)
    @merchant_account = payment.merchant_account
    options = {}
    options.merge!(@merchant_account.custom_options) if @merchant_account

    force_mode(payment.payment_gateway_mode)
    gateway_void(payment.authorization_token, options)
  end

  def gateway_void(token, options = {})
    gateway.void(token, options)
  rescue => e
    MarketplaceLogger.error(VOID_ERROR, e.to_s, raise: false)
    OpenStruct.new(success?: false, message: e.to_s)
  end

  def refund(amount, currency, payment, successful_charge)
    @payment = payment
    @merchant_account = @payment.merchant_account
    force_mode(payment.payment_gateway_mode)

    @refund = refunds.create(
      amount_cents: amount,
      currency: currency,
      payment: payment,
      payment_gateway_mode: mode,
      receiver: 'guest'
    )

    raise PaymentGateway::RefundNotSupportedError, "Refund isn't supported or is not implemented. Please refund this user directly on your gateway account." unless defined?(refund_identification)

    options = custom_refund_options.merge(currency: currency)
    options.merge!(@merchant_account.custom_options) if @merchant_account

    response = gateway_refund(amount, refund_identification(successful_charge), options.with_indifferent_access)
    response.success? ? refund_successful(response) : refund_failed(response)
    @refund
  end

  def gateway_refund(amount, token, options)
    gateway.refund(amount, token, options)
  rescue => e
    MarketplaceLogger.error(REFUND_ERROR, e.to_s, raise: false)
    OpenStruct.new(success?: false, message: e.to_s)
  end

  def store(credit_card, instance_client)
    force_mode(instance_client.test_mode? ? 'test' : 'live')
    options = { email: instance_client.client.email, default_card: true, customer: instance_client.customer_id }
    gateway_store(credit_card, options)
  end

  def gateway_store(credit_card, options)
    gateway.store(credit_card, options)
  rescue => e
    MarketplaceLogger.error(STORE_ERROR, e.to_s, raise: false)
    OpenStruct.new(success?: false, message: e.to_s, params: { 'error' => { 'message' => e.to_s } })
  end

  def gateway_delete(instance_client, options)
    gateway.delete(instance_client, options)
  rescue => e
    MarketplaceLogger.error(UNSTORE_ERROR, e.to_s, raise: false)
    OpenStruct.new(success?: false, message: e.to_s)
  end

  def store_credit_card(client, credit_card)
    return nil unless supports_recurring_payment?

    @instance_client = instance_clients.where(client: client).first_or_initialize
    options = { email: client.email, default_card: true, customer: @instance_client.customer_id }
    response = gateway.store(credit_card, options)
    @instance_client.response ||= response.to_yaml
    @instance_client.save!
    @credit_card = credit_cards.build(instance_client: @instance_client)
    @credit_card.response = response.to_yaml
    @credit_card.save!
    @credit_card.id
  end

  def payout(company, payout_details)
    force_mode(payout_details[:payment_gateway_mode])
    merchant_account = merchant_account(company)

    if merchant_account
      amount = payout_details[:amount]
      reference = payout_details[:reference]
      @payout = payouts.create(
        amount_cents: amount.cents,
        currency: amount.currency.iso_code,
        reference: reference,
        payment_gateway_mode: mode
      )
      process_payout(merchant_account, amount, reference)
      @payout
    else
      OpenStruct.new(success: false)
    end
  end

  def immediate_payout(_company)
    false
  end

  def merchant_account(company)
    return nil if company.nil?

    merchant_accounts.where(merchantable: company, test: test_mode?).where(state: 'verified').first
  end

  def translate_option_keys(options)
    options_key_map.each do |k, v|
      if (value = options.delete(k)).present?
        options[v] = value
      end
    end

    options
  end

  def underscored_name
    self.class.name.gsub('PaymentGateway::', '').underscore.gsub('_payment_gateway', '')
  end

  def merchant_account_type
    MerchantAccount::MERCHANT_ACCOUNTS[underscored_name]
  end

  def build_payment_methods(active = false)
    PaymentMethod::PAYMENT_METHOD_TYPES.each do |payment_method|
      if send("supports_#{payment_method}_payment?") && payment_methods.find_by(payment_method_type: payment_method).blank?
        payment_methods.build(payment_method_type: payment_method, active: active, instance_id: instance_id)
      end
    end
  end

  def max_refund_attempts
    3
  end

  protected

  def void_merchant_accounts
    mearchant_accounts.each(&:void!)
  end

  # Callback invoked by processor when charge was successful
  def charge_successful(response)
    @charge.charge_successful(response)
  end

  # Callback invoked by processor when charge failed
  def charge_failed(response)
    @charge.charge_failed(response)
    @payment.errors.add(:base, response.message) if response.respond_to?(:message)
  end

  # Callback invoked by processor when refund was successful
  def refund_successful(response)
    @refund.refund_successful(response)
  end

  # Callback invoked by processor when refund failed
  def refund_failed(response)
    @refund.refund_failed(response)
  end

  def custom_authorize_options(_payment = nil)
    {}
  end

  def custom_capture_options
    {}
  end

  def custom_refund_options
    {}
  end

  def options_key_map
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
