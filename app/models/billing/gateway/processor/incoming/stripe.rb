class Billing::Gateway::Processor::Incoming::Stripe < Billing::Gateway::Processor::Incoming::Base  
  def setup_api_on_initialize
    key = @instance.instance_payment_gateways.get_settings_for(:stripe, :api_key)
    @gateway = ActiveMerchant::Billing::StripeGateway.new(:login => key)
  end

  def refund_identification(charge_response)
    charge_response["id"]
  end
end
