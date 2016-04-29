class PaymentGateway::PaypalAdaptivePaymentGateway < PaymentGateway
  include PayPal::SDK::Core::Logging

  # Global setting for all marketplaces
  # Send to paypal with every action as BN CODE
  ActiveMerchant::Billing::Gateway.application_id = Rails.configuration.active_merchant_billing_gateway_app_id

  supported :payout, :multiple_currency

  def supported_currencies
   [
      "AUD", "BRL", "CAD", "CHF", "CZK", "DKK", "EUR", "GBP", "HDK", "HUF", "HKD", "ILS", "JPY", "MXN",
      "MYR", "NOK", "NZD", "PHP", "PLN", "RUB", "SEK", "SGD", "THB", "TRY", "TWD", "USD"
    ]
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

  def self.settings
    {
      email: { validate: [:presence] },
      login: { validate: [:presence] },
      password: { validate: [:presence] },
      signature: { validate: [:presence] },
      app_id: { validate: [:presence] },
    }
  end

  def documentation_url
    "https://developer.paypal.com/docs/classic/adaptive-payments/gs_AdaptivePayments/"
  end

  def payout_gateway
    if @payout_gateway.nil?
      PayPal::SDK.configure(
        :mode      => test_mode? ? "sandbox" : "live",
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

