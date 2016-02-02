class PaymentGateway::FetchPaymentGateway < PaymentGateway

  supported :multiple_currency, :remote_payment

  def self.settings
    {
      account_id: "",
      secret_key: ""
    }
  end

  attr_reader :payment_data
  attr_accessor :mns_params

  def self.supported_countries
    ['NZ']
  end

  def supported_currencies
    ["NZD"]
  end

  def logo_image
    'fetch-payment-logo.png'
  end

  def gateway_url
    if test_mode?
      "https://demo.fetchpayments.co.nz/webpayments/default.aspx"
    else
      "https://my.fetchpayments.co.nz/webpayments/default.aspx"
    end
  end

  def authorize(authoriazable, options = {})
    true
  end

  def verify
    mns_params.reject! { |k,v| ['action', 'controller', 'reservation_id'].include?(k) }
    mns_params.each { |k, v| mns_params[k] = v.gsub(/\s+/, '%20') }
    mns_params.merge!({'cmd' => '_xverify-transaction'})
    mns_url = gateway_url.gsub('default', 'MNSHandler')
    response = Net::HTTP.post_form(URI.parse(mns_url), mns_params)
    response.body == 'VERIFIED'
  end

  def set_payment_data(reservation)
    @payment_data = {
      account_id: settings[:account_id],
      amount: reservation.total_amount_dollars,
      return_url: return_url(reservation),
      notification_url: return_url(reservation),
      payment_method: 'standard'
    }

    calculate_merchant_verifier

    @payment_data.merge!({
      cmd: "_xclick",
      item_name: ERB::Util.url_encode(reservation.listing.name).truncate(40),
      store_card: "0"
    })
  end

  def return_url(reservation)
    protocol = PlatformContext.current.require_ssl? ? "https://" : "http://"
    host = PlatformContext.current.decorate.host
    path = "/reservations/#{reservation.id}/payment_notifications"
    return protocol + host + path
  end

  def charge(user, amount, currency, payment, token)
    @mns_params = payment.payment_response_params

    @charge = Charge.create(
      amount: amount,
      payment: payment,
      currency: currency,
      user_id: user.id,
    )

    if verify && mns_params["transaction_status"] == '2'
      charge_successful(mns_params)
    else
      charge_failed(mns_params)
    end
    @charge
  end

  private

  def calculate_merchant_verifier
    merchant_verifier =  Digest::SHA1.base64digest(@payment_data.values.join('') + settings[:secret_key])
    @payment_data.merge!(merchant_verifier: merchant_verifier)
  end
end

