class InstanceAdmin::Settings::PaymentsController < InstanceAdmin::Settings::BaseController
  before_filter :find_payment_gateways

  def index
  end

  private

  def find_payment_gateways
    @payment_gateways = PaymentGateway.order(:created_at)
  end

  def default_action
    :index
  end

  def payment_gateway_params(payment_gateway)
    params.require(:payment_gateway).permit(secured_params.payment_gateway).tap do |whitelisted|
      # we need to invoke slice like .slice(:a, :b) instead of .slice([:a, b]), hence the *
      whitelisted[:live_settings] = params[:payment_gateway][:live_settings].slice(*payment_gateway.class.settings.stringify_keys.keys)
      whitelisted[:test_settings] = params[:payment_gateway][:test_settings].slice(*payment_gateway.class.settings.stringify_keys.keys)
    end
  end
end
