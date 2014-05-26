class Billing::Gateway::Processor::Incoming::Ogone < Billing::Gateway::Processor::Incoming::Base  
  def setup_api_on_initialize
    settings = @instance.instance_payment_gateways.get_settings_for(:ogone)
    @gateway = ActiveMerchant::Billing::OgoneGateway.new(settings)
  end

  def self.supported_currencies
    ["EUR"]
  end
end
