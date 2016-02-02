class PaymentGateway::PaypalExpressPaymentGateway < PaymentGateway

  include ActionView::Helpers::SanitizeHelper
  include PaymentGateway::ActiveMerchantGateway

  # Global setting for all marketplaces
  # Send to paypal with every action as BN CODE
  ActiveMerchant::Billing::Gateway.application_id = Rails.configuration.active_merchant_billing_gateway_app_id

  supported :multiple_currency, :express_checkout_payment

  def self.settings
    {
      login: "",
      password: "",
      signature: "",
      partner_id: ""
    }
  end

  def self.active_merchant_class
    ActiveMerchant::Billing::PaypalExpressGateway
  end

  def self.supported_countries
    ["AL", "DZ", "AD", "AO", "AI", "AG", "AR", "AM", "AW", "AU", "AT", "AZ", "BS", "BH", "BB", "BE", "BZ", "BJ", "BM", "BT", "BO", "BA", "BW", "BR", "BN", "BG", "BF", "BI", "KH", "CA", "CV", "KY", "TD", "CL", "CN", "CO", "KM", "CD", "CG", "CK", "CR", "HR", "CY", "CZ", "DK", "DJ", "DM", "DO", "EC", "EG", "SV", "ER", "EE", "ET", "FK", "FJ", "FI", "FR", "GF", "PF", "GA", "GM", "GE", "DE", "GI", "GR", "GL", "GD", "GP", "GU", "GT", "GN", "GW", "GY", "VA", "HN", "HK", "HU", "IS", "IN", "ID", "IE", "IL", "IT", "JM", "JP", "JO", "KZ", "KE", "KI", "KR", "KW", "KG", "LA", "LV", "LS", "LI", "LT", "LU", "MG", "MW", "MY", "MV", "ML", "MT", "MH", "MQ", "MR", "MU", "YT", "MX", "FM", "MN", "MS", "MA", "MZ", "NA", "NR", "NP", "NL", "NC", "NZ", "NI", "NE", "NU", "NF", "NO", "OM", "PW", "PA", "PG", "PE", "PH", "PN", "PL", "PT", "QA", "RE", "RO", "RU", "RW", "SH", "KN", "LC", "PM", "VC", "WS", "SM", "ST", "SA", "SN", "RS", "SC", "SL", "SG", "SK", "SI", "SB", "SO", "ZA", "KR", "ES", "LK", "SR", "SJ", "SZ", "SE", "CH", "TW", "TJ", "TZ", "TH", "TG", "TO", "TT", "TN", "TR", "TM", "TC", "TV", "UG", "UA", "AE", "GB", "US", "UY", "VU", "VE", "VN", "VG", "WF", "YE", "ZM"]
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
        subject: subject,
        test: test_mode?
      )
    end
    @gateway
  end

  alias_method :express_gateway, :gateway

  def gateway_capture(amount, token, options)
    gateway(@payable.merchant_subject).capture(amount, token, options)
  end

  def custom_capture_options
    {
      token: @payable.express_token,
      payer_id: @payable.express_payer_id
    }
  end

  def process_express_checkout(transactable, options)
    @transactable = transactable
    @response = gateway(@transactable.merchant_subject).setup_authorization(@transactable.total_amount.cents, options.deep_merge(
      {
        currency: @transactable.currency,
        allow_guest_checkout: true,
        items: line_items + service_fee + additional_charges,
        subtotal: @transactable.total_amount.cents - @transactable.shipping_amount.cents - @transactable.tax_amount.cents,
        shipping: @transactable.shipping_amount.cents,
        handling: 0,
        tax: @transactable.tax_amount.cents
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

  private

  # Callback invoked by processor when charge was successful
  def charge_successful(response)
    if @payment.payable.billing_authorization.immediate_payout?
      @payment.company.payment_transfers.create!(payments: [@payment.reload], payment_gateway_mode: mode, payment_gateway_id: self.id)
    end
    @charge.charge_successful(response)
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
        amount: @transactable.service_fee_amount_guest.cents
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
