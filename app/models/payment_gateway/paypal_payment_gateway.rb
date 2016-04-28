class PaymentGateway::PaypalPaymentGateway < PaymentGateway
  include PayPal::SDK::Core::Logging
  include PaymentGateway::ActiveMerchantGateway
  include PaymentExtention::PaypalMerchantBoarding

  # Global setting for all marketplaces
  # Send to paypal with every action as BN CODE
  ActiveMerchant::Billing::Gateway.application_id = Rails.configuration.active_merchant_billing_gateway_app_id

  supported :multiple_currency, :credit_card_payment, :partial_refunds

  def self.supported_countries
    ["US", "GB", "CA"]
  end

  def supported_currencies
   [
      "AUD", "BRL", "CAD", "CHF", "CZK", "DKK", "EUR", "GBP", "HDK", "HUF", "HKD", "ILS", "JPY", "MXN",
      "MYR", "NOK", "NZD", "PHP", "PLN", "RUB", "SEK", "SGD", "THB", "TRY", "TWD", "USD"
    ]
  end

  def self.settings
    {
      login: "",
      password: "",
      signature: "",
    }
  end

  def self.active_merchant_class
    ActiveMerchant::Billing::PaypalGateway
  end

  def set_billing_agreement(options)
    @response = express_gateway.setup_authorization(0, options.deep_merge({ billing_agreement: {
      type: "MerchantInitiatedBilling",
      description: "#{PlatformContext.current.instance.name} Billing Agreement"
    }}))
  end

  def token
    @token ||= @response.token
  end

  def redirect_url
    gateway.redirect_url_for(token)
  end

  def express_gateway
    if @express_gateway.nil?
      @express_gateway = ActiveMerchant::Billing::PaypalExpressGateway.new(
        login: settings[:login],
        password: settings[:password],
        signature: settings[:signature],
        test: test_mode?
      )
    end
    @express_gateway
  end

  def gateway(subject=nil)
    if @gateway.nil? || subject.present?
      @gateway = self.class.active_merchant_class.new(
        login: settings[:login],
        password: settings[:password],
        signature: settings[:signature],
        subject: subject,
        test: test_mode?
      )
    end
    @gateway
  end

  def custom_authorize_options
    { ip: "127.0.0.1" }
  end

  def refund_identification(charge)
    charge.response.params["transaction_id"]
  end
end

