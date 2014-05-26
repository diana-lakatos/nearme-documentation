class Billing::Gateway::Processor::Incoming::Spreedly < Billing::Gateway::Processor::Incoming::Base  
  def setup_api_on_initialize
    settings = @instance.instance_payment_gateways.get_settings_for(:spreedly)
    @gateway = ActiveMerchant::Billing::SpreedlyCoreGateway.new(settings)
  end

  def self.support_any_currency!
    true
  end
end
