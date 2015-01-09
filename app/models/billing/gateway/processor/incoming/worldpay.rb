class Billing::Gateway::Processor::Incoming::Worldpay < Billing::Gateway::Processor::Incoming::Base  
  def setup_api_on_initialize
    settings = @instance.instance_payment_gateways.get_settings_for(:worldpay)
    @gateway = ActiveMerchant::Billing::WorldpayGateway.new(settings)
  end

  def refund_identification(charge)

  end
end
