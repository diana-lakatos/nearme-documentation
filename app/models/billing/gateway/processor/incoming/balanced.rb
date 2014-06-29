class Billing::Gateway::Processor::Incoming::Balanced < Billing::Gateway::Processor::Incoming::Base
  def setup_api_on_initialize
    settings = @instance.instance_payment_gateways.get_settings_for(:balanced)
    @gateway = active_merchant_class.new(settings)
  end

  def active_merchant_class
    ActiveMerchant::Billing::BalancedGateway
  end

  def custom_authorize_options
    { email: @user.email }
  end

  def refund_identification(charge_response)
    charge_response["uri"]
  end

  def self.supported_currencies
    ["USD"]
  end
end
