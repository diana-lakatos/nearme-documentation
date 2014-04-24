class Billing::Gateway::Processor::Incoming::Paypal < Billing::Gateway::Processor::Incoming::Base
  def setup_api_on_initialize
    settings = @instance.instance_payment_gateways.get_settings_for(:paypal)
    @gateway = ActiveMerchant::Billing::PaypalGateway.new(
      login: settings[:username],
      password: settings[:password],
      signature: settings[:signature]
    )
  end

  def custom_authorize_options
    { ip: "127.0.0.1" }
  end

  def refund_identification(charge_response)
    charge_response["transaction_id"]
  end
end
