class PaymentGateway::PaypalAdaptivePaymentGateway < PaymentGateway
  include PayPal::SDK::Core::Logging

  # Global setting for all marketplaces
  # Send to paypal with every action as BN CODE
  ActiveMerchant::Billing::Gateway.application_id = Rails.configuration.active_merchant_billing_gateway_app_id

  supported :payout, :multiple_currency

  def supported_currencies
    ["AUD", "BRL", "CZK", "DKK", "HDK", "HUF", "ILS", "MYR", "MXN", "NOK", "NZD", "PHP", "RUB", "SGD", "SEK", "CHF", "TWD", "THB", "TRY",  "USD", "GBP", "EUR", "JPY", "CAD", "PLN"]
  end

  def self.supported_countries
    %w{ AL DZ AD AO AI AG AR AM AW AU AT BS BH BB BY BE BZ BJ BM BT BA BW BR BG BF BI KH CM CA CV KY TD CL CN CO KM CK CR HR CY CZ DK DJ DM DO EC EG SV ER EE ET FO FJ FI FR GF PF GM GE DE GI GR GL GD GP GT GN GW GY HN HK HU IS IN ID IE IL IT JM JP JO KZ KE KI KW KG LV LS LI LT LU MG MW MY MV ML MT MH MQ MR MU YT MX MC MN ME MS MA MZ NA NR NP NL NC NZ NI NE NG NU NF NO OM PW PA PG PY PE PH PL PT QA RO RW KN LC PM VC WS SM ST SA SN RS SC SL SG SK SI SB SO ZA ES LK SR SJ SZ SE CH TW TJ TH TG TO TT TN TR TM TV UG UA AE GB US UY VU WF YE ZM ZW}
  end

  def self.settings
    {
      email: "",
      login: "",
      password: "",
      signature: "",
      app_id: "",
    }
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

  def process_payout(merchant_account, amount, reference)
    @pay = payout_gateway.build_pay({
      :actionType => "PAY",
      :currencyCode => amount.currency.iso_code,
      :feesPayer => "SENDER",
      :cancelUrl => "http://#{Rails.application.routes.default_url_options[:host]}",
      :returnUrl => "http://#{Rails.application.routes.default_url_options[:host]}",
      :receiverList => {
        :receiver => [{
          :amount => amount.to_s,
          :email => merchant_account.email
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
      payout_failed(@pay_response)
    end
  end

  def custom_authorize_options
    { ip: "127.0.0.1" }
  end

end

