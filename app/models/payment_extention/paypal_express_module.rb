module PaymentExtention::PaypalExpressModule
  MAX_REFUND_ATTEMPTS = 4

  ActiveMerchant::Billing::Gateway.application_id = Rails.configuration.active_merchant_billing_gateway_app_id

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def self.active_merchant_class
      ActiveMerchant::Billing::PaypalExpressGateway
    end
    def all_supported_by_pay_pal
      %w(AL DZ AD AO AI AG AR AM AW AU AT AZ BS BH BB BE BZ BJ BM BT BO BA BW BR BN BG BF BI KH CA CV KY TD CL CN CO KM CD CG CK CR HR CY CZ DK DJ DM DO EC EG SV ER EE ET FK FJ FI FR GF PF GA GM GE DE GI GR GL GD GP GU GT GN GW GY VA HN HK HU IS IN ID IE IL IT JM JP JO KZ KE KI KR KW KG LA LV LS LI LT LU MG MW MY MV ML MT MH MQ MR MU YT MX FM MN MS MA MZ NA NR NP NL NC NZ NI NE NU NF NO OM PW PA PG PE PH PN PL PT QA RE RO RU RW SH KN LC PM VC WS SM ST SA SN RS SC SL SG SK SI SB SO ZA KR ES LK SR SJ SZ SE CH TW TJ TZ TH TG TO TT TN TR TM TC TV UG UA AE GB US UY VU VE VN VG WF YE ZM BY CM FO MK MD MC ME MM AN NG PY ZW)
    end
  end

  def settings
    super.merge(subject: subject, test: test_mode?)
  end

  def gateway(subject = nil)
    if @gateway.nil? || subject.present?
      @gateway = self.class.active_merchant_class.new(settings_hash)
    end
    @gateway
  end

  def process_express_checkout(order, options)
    @order = order
    @response = express_gateway.setup_authorization(@order.total_amount.cents, options.deep_merge(
                                                                                 currency: @order.currency,
                                                                                 allow_guest_checkout: true,
                                                                                 items: line_items,
                                                                                 subtotal: @order.total_amount.cents - @order.shipping_total.cents - @order.total_tax_amount.cents,
                                                                                 shipping: @order.shipping_total.cents,
                                                                                 handling: 0,
                                                                                 tax: @order.total_tax_amount.cents)
                                                   )
    # TODO: store @response somewhere
  end

  def refund_identification(charge)
    charge.response.params['transaction_id']
  end

  def supports_paypal_chain_payments?
    settings[:partner_id].present?
  end

  def redirect_url
    gateway.redirect_url_for(token)
  end

  def token
    @token ||= @response.token
  end

  def supported_currencies
    %w(AUD BRL CAD CHF CZK DKK EUR GBP HDK HUF HKD ILS JPY MXN MYR NOK NZD PHP PLN RUB SEK SGD THB TRY TWD USD)
  end

  def gateway_authorize(amount, payer_id, options)
    express_gateway(options.delete(:merchant_account_id)).authorize(amount, options.merge(payer_id: payer_id))
  end

  def gateway_capture(amount, token, options)
    express_gateway.capture(amount, token, options)
  end

  def line_items
    @order.line_items.map do |i|
      {
        name: i.name.try(:strip),
        description: i.respond_to?(:description) ? strip_tags(i.description.to_s.strip) : '',
        quantity: i.quantity.to_i,
        amount: i.gross_price_cents
      }
    end
  end

  def max_refund_attempts
    MAX_REFUND_ATTEMPTS
  end

  def documentation_url
    'https://developer.paypal.com/docs/classic/express-checkout/integration-guide/ECGettingStarted/'
  end

  private

  # Callback invoked by processor when charge was successful
  def charge_successful(response)
    if @payment.successful_billing_authorization.immediate_payout?
      @payment.company.payment_transfers.create!(payments: [@payment.reload], payment_gateway_mode: mode, payment_gateway_id: id)
    end
    @charge.charge_successful(response)
  end
end
