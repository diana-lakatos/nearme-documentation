class Billing::Gateway::Processor::Incoming::Paypal < Billing::Gateway::Processor::Incoming::Base
  def setup_api_on_initialize
    settings = @instance.instance_payment_gateways.get_settings_for(:paypal)
    @gateway = active_merchant_class.new(
      login: settings[:login],
      password: settings[:password],
      signature: settings[:signature]
    )
  end

  def active_merchant_class
    ActiveMerchant::Billing::PaypalGateway
  end

  def custom_authorize_options
    ip_address = @user.current_sign_in_ip.present? ? @user.current_sign_in_ip : "127.0.0.1" # Just in case user IP is null...
    { ip: ip_address }
  end

  def refund_identification(charge_response)
    charge_response["transaction_id"]
  end

  def self.supported_currencies
    ["USD", "GBP", "EUR", "JPY", "CAD"]
  end

end

