class Billing::Gateway::Processor::Incoming::SagePay < Billing::Gateway::Processor::Incoming::Base  
  def setup_api_on_initialize
    settings = @instance.instance_payment_gateways.get_settings_for(:sagepay)
    @gateway = ActiveMerchant::Billing::SagePayGateway.new(settings)
  end

  def refund_identification(charge_response)
    
  end
end
