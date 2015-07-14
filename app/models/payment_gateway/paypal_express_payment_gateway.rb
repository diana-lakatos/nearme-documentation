class PaymentGateway::PaypalExpressPaymentGateway < PaymentGateway

  include ActionView::Helpers::SanitizeHelper
  include PaymentGateway::ActiveMerchantGateway
  include PaymentExtention::PaypalMerchantBoarding

  has_many :merchant_accounts, class_name: 'MerchantAccount::PaypalMerchantAccount'

  # Global setting for all marketplaces
  # Send to paypal with every action as BN CODE
  ActiveMerchant::Billing::Gateway.application_id = 'NearMe_SP'

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
    ActiveMerchant::Billing::PaypalExpressGateway
  end

  def self.supported_countries
    ["US", "GB", "PL"]
  end

  def authorize(authoriazable, options = {})
    PaymentAuthorizer::PaypalExpressPaymentAuthorizer.new(self, authoriazable, options).process!
  end

  def gateway_capture(amount, token, options)
    gateway(@payable.merchant_payer_id).capture(amount, token, options)
  end

  def custom_capture_options
    {
      token: @payable.express_token,
      payer_id: @payable.express_payer_id
    }
  end

  def express_checkout?
    true
  end

  def supports_boarding_merchant?
    true
  end

  def type_name
    "paypal"
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

  def immediate_payout(company)
    merchant_account(company).present?
  end

  def payout(company, options)
    response = gateway.reference_transaction(options[:reference].total_service_fee_cents, { reference_id: merchant_account(company).billing_agreement_id })
    OpenStruct.new(success: response.success?)
  end

  def process_express_checkout(transactable, options)
    @transactable = transactable
    @response = gateway(@transactable.merchant_payer_id).setup_authorization(@transactable.total_amount_cents , options.deep_merge(
      {
        currency: @transactable.currency,
        allow_guest_checkout: true,
        items: line_items + service_fee + additional_charges,
        subtotal: @transactable.total_amount_cents_without_shipping,
        shipping: @transactable.shipping_costs_cents,
        handling: 0,
        tax: @transactable.tax_total_cents
      })
    )
  end

  def set_billing_agreement(options)
    @response = gateway.setup_authorization(0, options.deep_merge({ billing_agreement: {
      type: "MerchantInitiatedBilling",
      description: "#{PlatformContext.current.instance.name} Billing Agreement"
    }}))
  end

  def redirect_url
    gateway.redirect_url_for(token)
  end

  def refund_identification(charge)
    charge.response.params["transaction_id"]
  end

  def supported_currencies
    ["USD", "GBP", "EUR", "JPY", "CAD", "PLN"]
  end

  def token
    @token ||= @response.token
  end

  def supports_payout?
    true
  end

  def supports_paypal_chain_payments?
    settings[:partner_id].present?
  end

  private

  # Callback invoked by processor when charge was successful
  def charge_successful(response)
    if @payment.payable.billing_authorization.immediate_payout?
      @payment.company.payment_transfers.create!(payments: [@payment.reload], payment_gateway_mode: mode, payment_gateway_id: self.id)
    end
    @charge.charge_successful(response)
  end


  def merchant_payer_id
    @merchant_account.payer_id
  end

  def line_items
    @transactable.line_items.map { |i|
      {
        name: i.name.strip,
        description: i.respond_to?(:description) ? strip_tags(i.description.strip) : '',
        quantity: i.quantity.to_i,
        amount: i.price_in_cents
      }
    }
  end

  def service_fee
    [
      {
        name: I18n.t('buy_sell_market.checkout.labels.service_fee'),
        quantity: 1,
        amount: @transactable.service_fee_guest_without_charges.cents
      }
    ]
  end

  def additional_charges
    @transactable.additional_charges.map do |charge|
      {
        name: charge.name,
        quantity: 1,
        amount: charge.amount.cents
      }
    end
  end
end
