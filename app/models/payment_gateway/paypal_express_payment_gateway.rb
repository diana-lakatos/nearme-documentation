include ActionView::Helpers::SanitizeHelper

class PaymentGateway::PaypalExpressPaymentGateway < PaymentGateway
  include PayPal::SDK::Core::Logging
  include PaymentGateway::ActiveMerchantGateway

  def self.settings
    {
      email: "",
      login: "",
      password: "",
      signature: "",
      app_id: ""
    }
  end

  def authorize(authoriazable, options = {})
    PaymentAuthorizer::PaypalExpressPaymentAuthorizer.new(self, authoriazable, options).process!
  end

  def custom_capture_options
    {
      token: @payable.express_token,
      payer_id: @payable.express_payer_id
    }
  end

  def self.active_merchant_class
    ActiveMerchant::Billing::PaypalExpressGateway
  end

  def express_checkout?
    true
  end

  def process_express_checkout(transactable, options)
    @transactable = transactable
    @response = gateway.setup_authorization(@transactable.total_amount_cents , options.merge(
      {
        currency: @transactable.currency,
        allow_guest_checkout: true,
        items: line_items + service_fee + additional_charges,
        subtotal: @transactable.subtotal_amount_cents,
        shipping: 0,
        handling: 0,
        tax: @transactable.tax_total_cents
      })
    )
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
    PlatformContext.current.instance.additional_charge_types.mandatory_charges.map do |charge|
      {
        name: charge.name,
        quantity: 1,
        amount: charge.amount.cents
      }
    end
  end

  def gateway
    if @gateway.nil?
      ActiveMerchant::Billing::Base.mode = :test if test_mode?
      @gateway = self.class.active_merchant_class.new(
        login: settings[:login],
        password: settings[:password],
        signature: settings[:signature]
      )
    end
    @gateway
  end

  def host
    "http://#{Rails.application.routes.default_url_options[:host]}"
  end

  def redirect_url
    gateway.redirect_url_for(token)
  end

  def token
    @token ||= @response.token
  end

  def supported_currencies
    ["USD", "GBP", "EUR", "JPY", "CAD"]
  end

  def supports_payout?
    false
  end

  def refund_identification(charge)
    charge.response.params["transaction_id"]
  end
end

