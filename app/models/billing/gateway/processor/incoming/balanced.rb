class Billing::Gateway::Processor::Incoming::Balanced < Billing::Gateway::Processor::Incoming::Base  
  def setup_api_on_initialize
    key = @instance.instance_payment_gateways.get_settings_for(:balanced, :api_key)
    @gateway = ActiveMerchant::Billing::BalancedGateway.new(:login => key)
  end

  def authorize_custom_options
    { email: @user.email }
  end

  def refund_identification(charge_response)
    charge_response["uri"]
  end
end
