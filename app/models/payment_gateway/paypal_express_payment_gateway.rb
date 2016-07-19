class PaymentGateway::PaypalExpressPaymentGateway < PaymentGateway

  include ActionView::Helpers::SanitizeHelper
  include PaymentGateway::ActiveMerchantGateway

  MAX_REFUND_ATTEMPTS = 4

  # Global setting for all marketplaces
  # Send to paypal with every action as BN CODE
  ActiveMerchant::Billing::Gateway.application_id = Rails.configuration.active_merchant_billing_gateway_app_id

  supported :multiple_currency, :express_checkout_payment, :partial_refunds

  def self.settings
    {
      login: { validate: [:presence] },
      password: { validate: [:presence] },
      signature: { validate: [:presence] },
      partner_id: { validate: [:presence] }
    }
  end

  def self.active_merchant_class
    ActiveMerchant::Billing::PaypalExpressGateway
  end

  def self.supported_countries
    [
      "AL", "DZ", "AD", "AO", "AI", "AG", "AR", "AM", "AW", "AU", "AT", "AZ", "BS",
      "BH", "BB", "BE", "BZ", "BJ", "BM", "BT", "BO", "BA", "BW", "BR", "BN", "BG",
      "BF", "BI", "KH", "CA", "CV", "KY", "TD", "CL", "CN", "CO", "KM", "CD", "CG",
      "CK", "CR", "HR", "CY", "CZ", "DK", "DJ", "DM", "DO", "EC", "EG", "SV", "ER",
      "EE", "ET", "FK", "FJ", "FI", "FR", "GF", "PF", "GA", "GM", "GE", "DE", "GI",
      "GR", "GL", "GD", "GP", "GU", "GT", "GN", "GW", "GY", "VA", "HN", "HK", "HU",
      "IS", "IN", "ID", "IE", "IL", "IT", "JM", "JP", "JO", "KZ", "KE", "KI", "KR",
      "KW", "KG", "LA", "LV", "LS", "LI", "LT", "LU", "MG", "MW", "MY", "MV", "ML",
      "MT", "MH", "MQ", "MR", "MU", "YT", "MX", "FM", "MN", "MS", "MA", "MZ", "NA",
      "NR", "NP", "NL", "NC", "NZ", "NI", "NE", "NU", "NF", "NO", "OM", "PW", "PA",
      "PG", "PE", "PH", "PN", "PL", "PT", "QA", "RE", "RO", "RU", "RW", "SH", "KN",
      "LC", "PM", "VC", "WS", "SM", "ST", "SA", "SN", "RS", "SC", "SL", "SG", "SK",
      "SI", "SB", "SO", "ZA", "KR", "ES", "LK", "SR", "SJ", "SZ", "SE", "CH", "TW",
      "TJ", "TZ", "TH", "TG", "TO", "TT", "TN", "TR", "TM", "TC", "TV", "UG", "UA",
      "AE", "GB", "US", "UY", "VU", "VE", "VN", "VG", "WF", "YE", "ZM", "BY", "CM",
      "FO", "MK", "MD", "MC", "ME", "MM", "AN", "NG", "PY", "ZW"]
  end

  def supported_currencies
    ["AUD", "BRL", "CZK", "DKK", "HDK", "HUF", "ILS", "MYR", "MXN", "NOK", "NZD", "PHP", "RUB", "SGD", "SEK", "CHF", "TWD", "THB", "TRY",  "USD", "GBP", "EUR", "JPY", "CAD", "PLN"]
  end

  def authorize(authoriazable, options = {})
    PaymentAuthorizer::PaypalExpressPaymentAuthorizer.new(self, authoriazable, options).process!
  end

  def gateway(subject=nil)
    if @gateway.nil? || subject.present?
      @gateway = self.class.active_merchant_class.new(
        login: settings[:login],
        password: settings[:password],
        signature: settings[:signature],
        test: test_mode?
      )
    end
    @gateway
  end

  alias_method :express_gateway, :gateway

  def gateway_capture(amount, token, options)
    gateway.capture(amount, token, options)
  end

  def process_express_checkout(order, options)
    @order = order
    @response = gateway.setup_authorization(@order.total_amount.cents, options.deep_merge(
      {
        currency: @order.currency,
        allow_guest_checkout: true,
        items: line_items, #+ service_fee + additional_charges,
        subtotal: @order.total_amount.cents - @order.shipping_total.cents - @order.total_tax_amount.cents,
        shipping: @order.shipping_total.cents,
        handling: 0,
        tax: @order.total_tax_amount.cents
      })
    )
    # TODO: store @response somewhere
  end

  def redirect_url
    gateway.redirect_url_for(token)
  end

  def refund_identification(charge)
    charge.response.params["transaction_id"]
  end

  def token
    @token ||= @response.token
  end

  def supports_paypal_chain_payments?
    settings[:partner_id].present?
  end

  def documentation_url
    "https://developer.paypal.com/docs/classic/express-checkout/integration-guide/ECGettingStarted/"
  end

  def max_refund_attempts
    MAX_REFUND_ATTEMPTS
  end

  private

  # Callback invoked by processor when charge was successful
  def charge_successful(response)
    if @payment.successful_billing_authorization.immediate_payout?
      @payment.company.payment_transfers.create!(payments: [@payment.reload], payment_gateway_mode: mode, payment_gateway_id: self.id)
    end
    @charge.charge_successful(response)
  end

  def line_items
    @order.line_items.map { |i|
      {
        name: i.name.strip,
        description: i.respond_to?(:description) ? strip_tags(i.description.to_s.strip) : '',
        quantity: i.quantity.to_i,
        amount: i.total_price_cents
      }
    }
  end

  # def service_fee
  #   [
  #     {
  #       name: I18n.t('buy_sell_market.checkout.labels.service_fee'),
  #       quantity: 1,
  #       amount: @order.service_fee_amount_guest.cents
  #     }
  #   ]
  # end

  # def additional_charges
  #   @order.additional_charges.map do |charge|
  #     {
  #       name: charge.name,
  #       quantity: 1,
  #       amount: charge.amount.cents
  #     }
  #   end
  # end
end
