class Billing::Gateway::Processor::Incoming::Paystation < Billing::Gateway::Processor::Incoming::Base  
  def setup_api_on_initialize
    settings = @instance.instance_payment_gateways.get_settings_for(:paystation)
    @gateway = ActiveMerchant::Billing::PaystationGateway.new(settings)
  end

  def self.supported_currencies
    ["NZD"]
  end
end
