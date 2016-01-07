class PaymentGateway < ActiveRecord::Base
  class PaymentGateway::PaymentAttemptError < StandardError; end
  class PaymentGateway::PaymentRefundError < StandardError; end
  class PaymentGateway::RefundNotSupportedError < StandardError; end
  class PaymentGateway::InvalidStateError < StandardError; end

  self.inheritance_column = :type
  auto_set_platform_context
  scoped_to_platform_context

  scope :mode_scope, -> { test_mode? ? where(test_active: true) : where(live_active: true)}
  scope :payout_type, -> { where(type: PAYOUT_GATEWAYS.values + IMMEDIATE_PAYOUT_GATEWAYS.values) }
  scope :payment_type, -> { where.not(type: PAYOUT_GATEWAYS.values) }

  serialize :test_settings, Hash
  serialize :live_settings, Hash

  belongs_to :instance
  belongs_to :payment_gateway

  has_many :charges
  has_many :refunds
  has_many :billing_authorizations
  has_many :payouts
  has_many :instance_clients
  has_many :credit_cards
  has_many :merchant_accounts

  has_many :payment_gateways_countries
  has_many :payment_countries, through: :payment_gateways_countries, source: 'country'

  has_many :payment_gateways_currencies
  has_many :payment_currencies, through: :payment_gateways_currencies, source: 'currency'

  has_many :payment_methods
  has_many :active_payment_methods, -> (object) { active.except_free },  class_name: "PaymentMethod"
  has_many :active_free_payment_methods, -> (object) { active.free }, class_name: "PaymentMethod"

  accepts_nested_attributes_for :payment_methods, :reject_if => :all_blank

  validates :payment_countries, presence: true, if: Proc.new { |p| p.active? && !p.supports_payout? }
  validates :payment_currencies, presence: true, if: Proc.new { |p| p.active? && !p.supports_payout? }
  validates :payment_methods, presence: true, if: Proc.new { |p| p.active? && !p.supports_payout?}
  validate do
    errors.add(:payment_methods, "At least one payment method must be selected") if active? && !supports_payout? && !payment_methods.any?{ |p| p.active? }
  end

  PAYOUT_GATEWAYS = {
    'PayPal Adpative Payments (Payouts)' => 'PaymentGateway::PaypalAdaptivePaymentGateway',
  }

  IMMEDIATE_PAYOUT_GATEWAYS = {
    'Braintree Marketplace' => 'PaymentGateway::BraintreeMarketplacePaymentGateway',
    'PayPal Express In Chain Payments' => 'PaymentGateway::PaypalExpressChainPaymentGateway',
    'Stripe Connect' => 'PaymentGateway::StripeConnectPaymentGateway',
  }

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
    'Offline Payment' => 'PaymentGateway::ManualPaymentGateway',
  }

  # supported/unsuppoted class method definition in config/initializers/act_as_supported.rb

  unsupported :payout, :recurring_payment, :any_country, :any_currency, :paypal_express_payment, :paypal_chain_payments,
    :multiple_currency, :express_checkout_payment, :nonce_payment, :company_onboarding, :remote_paymnt,
    :recurring_payment, :credit_card_payment, :manual_payment, :remote_payment, :free_payment, :immediate_payout, :free_payment,
    :partial_refunds

  attr_encrypted :test_settings, :live_settings, key: DesksnearMe::Application.config.secret_token, marshal: true

  attr_accessor :country

  #- CLASS METHODS STARTS HERE

  def self.supported_countries
    raise NotImplementedError.new("#{self.name} has not implemented self.supported_countries")
  end

  def active?
    self.live_active? || self.test_active?
  end

  def client_token
    nil
  end

  def supported_currencies
    []
  end

  def self.find_or_initialize_by_gateway_name(gateway_name)
    PaymentGateway.where(type: PaymentGateway::PAYMENT_GATEWAYS[gateway_name].to_s).first || PaymentGateway::PAYMENT_GATEWAYS[gateway_name].new
  end

  def self.find_or_initialize_by_type(type)
    PaymentGateway.where(type: type.to_s).first || PaymentGateway::PAYMENT_GATEWAYS.values.find { |value| value.to_s == type }.new
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

  def self.model_name
    ActiveModel::Name.new(PaymentGateway)
  end

  #- END CLASS METHODS

  def authorize(authoriazable, options = {})
    options.merge!(custom_authorize_options)
    PaymentAuthorizer.new(self, authoriazable, options).process!
  end

  def editable?
    true # TODO figure out if there is a case when we should block edition for payment_gateway
  end

  def deletable?
    true # TODO figure out if there is a case when we should block delete for payment_gateway
  end

  def name
    @name ||= PaymentGateway::PAYMENT_GATEWAYS.key(self.class.name)
  end

  def gateway
    raise NotImplementedError
  end

  def parse_webhook(*args)
    raise NotImplementedError
  end

  def verify_webhook(*args)
    raise NotImplementedError
  end

  def host
    port = ":3000"
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
      Currency.where(iso_code: self.supported_currencies).order(:name)
    end
  end

  def settings
    (test_mode? ? test_settings || {} : live_settings || {}).with_indifferent_access
  end

  def supports_currency?(currency)
    return true if self.supports_any_currency?
    self.supported_currencies.include?(currency)
  end

  def configured?(country_alpha2_code)
    settings.present? && payment_countries.where(iso: country_alpha2_code).any?
  end

  def self.test_mode?
    @test_mode.nil? ? PlatformContext.current.try {|c| c.instance.test_mode? } : @test_mode
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

  def charge(user, amount, currency, payment, token)
    @payment = payment
    @payable = @payment.payable
    @charge = charges.create(
      amount: amount,
      payment: payment,
      currency: currency,
      user_id: user.id,
      payment_gateway_mode: mode
    )

    begin
      options = custom_capture_options.merge(currency: currency)
      response = gateway_capture(amount, token, options.with_indifferent_access)
      response.success? ? charge_successful(response) : charge_failed(response)
      @charge
    rescue => e
      raise PaymentGateway::PaymentAttemptError, e
    end
  end

  def gateway_capture(amount, token, options)
    gateway.capture(amount, token, options)
  end

  def void(billing_authorization)
    force_mode(billing_authorization.payment_gateway_mode)
    gateway.void(billing_authorization.token)
  end

  def refund(amount, currency, payment, charge)
    @payment = payment
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
      response = gateway_refund(amount, charge, options.with_indifferent_access)
      response.success? ? refund_successful(response) : refund_failed(response)
      @refund
    rescue => e
      raise PaymentGateway::PaymentRefundError, e
    end
  end

  def gateway_refund(amount, charge, options)
    gateway.refund(amount, refund_identification(charge), options)
  end

  def store_credit_card(client, credit_card)
    return nil unless supports_recurring_payment?

    @instance_client = self.instance_clients.where(client: client).first_or_initialize
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
      amount, reference = payout_details[:amount], payout_details[:reference]
      @payout = payouts.create(
        amount: amount.cents,
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

  def immediate_payout(company)
    false
  end

  def onboard!(*args)
    raise NotImplementedError
  end

  def merchant_account(company)
    return nil if company.nil?

    merchant_account_class = self.class.name.gsub('PaymentGateway', 'MerchantAccount').safe_constantize
    if merchant_account_class
      merchant_account_class.where(merchantable: company, test: merchant_account_class::SEPARATE_TEST_ACCOUNTS && test_mode?).where(state: 'verified').first
    end
  end


  def build_payment_methods(active = false)
    PaymentMethod::PAYMENT_METHOD_TYPES.each do |payment_method|
      if self.send("supports_#{payment_method}_payment?") && payment_methods.find_by_payment_method_type(payment_method).blank?
        payment_methods.build(payment_method_type: payment_method, active: active, instance_id: self.instance_id)
      end
    end
  end

  protected

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

