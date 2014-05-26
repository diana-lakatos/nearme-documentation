class Billing::Gateway::Processor::Incoming::AuthorizeNet < Billing::Gateway::Processor::Incoming::Base  
  def setup_api_on_initialize
    settings = @instance.instance_payment_gateways.get_settings_for(:authorize_net)
    @gateway = ActiveMerchant::Billing::AuthorizeNetGateway.new(settings)
  end

  def self.supported_currencies
    ["USD", "CAD"]
  end
end
