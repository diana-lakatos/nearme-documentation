class Billing::Gateway::Processor::Incoming::Fetch < Billing::Gateway::Processor::Incoming::Base
  attr_reader :payment_data
  attr_accessor :mns_params

  def self.supported_countries
    ['NZ']
  end

  def self.supported_currencies
    ["NZD"]
  end

  def remote?
    return true
  end

  def setup_api_on_initialize
    @settings = @instance.instance_payment_gateways.get_settings_for(:fetch)
  end

  def logo_image
    'fetch-payment-logo.png'
  end

  def gateway_url
    if @instance.test_mode?
      "https://demo.fetchpayments.co.nz/webpayments/default.aspx"
    else
      "https://my.fetchpayments.co.nz/webpayments/default.aspx"
    end
  end

  def verify
    mns_params.reject! { |k,v| ['action', 'controller', 'reservation_id'].include?(k) }
    mns_params.each { |k, v| mns_params[k] = v.gsub(/\s+/, '%20') }
    mns_params.merge!({'cmd' => '_xverify-transaction'})
    mns_url = gateway_url.gsub('default', 'MNSHandler')
    response = Net::HTTP.post_form(URI.parse(mns_url), mns_params)
    response.body == 'VERIFIED'
  end

  def set_payment_data(reservation, request)
    @payment_data = {
      account_id: @settings[:account_id],
      amount: reservation.total_amount_dollars,
      return_url: "http://#{request.host_with_port}/reservations/#{reservation.id}/payment_notifications",
      notification_url: "http://#{request.host_with_port}/reservations/#{reservation.id}/payment_notifications",
      payment_method: 'standard'
    }

    calculate_merchant_verifier

    @payment_data.merge!({
      cmd: "_xclick",
      item_name: reservation.listing.name.gsub(/\s/, '%20'),
      store_card: "0"
    })
  end

  def charge(amount, reference, token)
    @mns_params = reference.reservation.payment_response_params

    unless verify
      raise Billing::Gateway::PaymentAttemptError, "Failed authorization of Fetch MNS response"
    end

    @charge = Charge.create(
      amount: amount,
      reference: reference,
      currency: @currency,
      user_id: @user.id,
    )

    if mns_params["transaction_status"] == '2'
      charge_successful(mns_params)
    else
      charge_failed(mns_params)
      raise Billing::Gateway::PaymentAttemptError, mns_params["response_text"]
    end
  end


  private

  def calculate_merchant_verifier
    merchant_verifier =  Digest::SHA1.base64digest(@payment_data.values.join('') + @settings[:secret_key])
    @payment_data.merge!(merchant_verifier: merchant_verifier)
  end
end

