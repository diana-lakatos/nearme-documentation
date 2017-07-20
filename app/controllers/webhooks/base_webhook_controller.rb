class Webhooks::BaseWebhookController < Webhooks::BaseController
  skip_before_action :redirect_if_marketplace_password_protected
  before_action :find_payment_gateway

  protect_from_forgery except: :webhook

  protected

  def find_payment_gateway
    @payment_gateway ||= PaymentGateway.where(type: payment_gateway_class).mode_scope.first!
  end

  def payment_gateway_class
    raise NotImplementedError
  end
end
