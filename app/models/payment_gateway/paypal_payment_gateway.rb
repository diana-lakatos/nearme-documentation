class PaymentGateway::PaypalPaymentGateway < PaymentGateway
  include PayPal::SDK::Core::Logging
  include PaymentGateway::ActiveMerchantGateway
  include PaymentExtention::PaypalMerchantBoarding

  # Global setting for all marketplaces
  # Send to paypal with every action as BN CODE
  ActiveMerchant::Billing::Gateway.application_id = Rails.configuration.active_merchant_billing_gateway_app_id

  def self.settings
    {
      email: "",
      login: "",
      password: "",
      signature: "",
      app_id: "",
      partner_id: ""
    }
  end

  def self.active_merchant_class
    ActiveMerchant::Billing::PaypalGateway
  end

  def authorize(authoriazable, options = {})
    PaymentAuthorizer::PaypalPaymentAuthorizer.new(self, authoriazable, options.merge(custom_authorize_options)).process!
  end

  def payout_gateway
    if @payout_gateway.nil?
      PayPal::SDK.configure(
        :app_id    => (test_mode? || !Rails.env.production?) ? 'APP-80W284485P519543T' : settings[:app_id],
        :username  => settings[:login],
        :password  => settings[:password],
        :signature => settings[:signature]
      )
      @payout_gateway = PayPal::SDK::AdaptivePayments::API.new
    end
    @payout_gateway
  end

  def payout_supports_country?(country)
    true
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
      ActiveMerchant::Billing::Base.mode = :test if test_mode?
      @express_gateway = ActiveMerchant::Billing::PaypalExpressGateway.new(
        login: settings[:login],
        password: settings[:password],
        signature: settings[:signature]
      )
    end
    @express_gateway
  end

  def process_payout(merchant_account, amount)
    @pay = payout_gateway.build_pay({
      :actionType => "PAY",
      :currencyCode => amount.currency.iso_code,
      :feesPayer => "SENDER",
      :cancelUrl => "http://#{Rails.application.routes.default_url_options[:host]}",
      :returnUrl => "http://#{Rails.application.routes.default_url_options[:host]}",
      :receiverList => {
        :receiver => [{
          :amount => amount.to_s,
          :email => merchant_account.data[:email]
        }]
      },
      :senderEmail => settings[:email]
    })
    @pay_response = payout_gateway.pay(@pay)
    if @pay_response.success?
      if @pay_response.paymentExecStatus == 'COMPLETED'
        payout_successful(@pay_response)
      elsif @pay_response.paymentExecStatus == 'CREATED'
        payout_pending(@pay_response)
      else
        raise "Unknown payment exec status: #{@pay_response.paymentExecStatus}"
      end
    else
      payout_failed(@pay_response.error)
    end
  end

  def gateway(subject=nil)
    if @gateway.nil? || subject.present?
      ActiveMerchant::Billing::Base.mode = :test if test_mode?
      @gateway = self.class.active_merchant_class.new(
        login: settings[:login],
        password: settings[:password],
        signature: settings[:signature],
        subject: subject
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

  def supports_payout?
    true
  end

  def supports_paypal_chain_payments?
    false
  end

  def supported_currencies
    ["USD", "GBP", "EUR", "JPY", "CAD"]
  end


end

