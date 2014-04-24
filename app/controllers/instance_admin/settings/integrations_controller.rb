class InstanceAdmin::Settings::IntegrationsController < InstanceAdmin::Settings::BaseController
  before_filter :find_payment_gateways

  def find_payment_gateways
    @payment_gateways = PaymentGateway.all
  end
end
