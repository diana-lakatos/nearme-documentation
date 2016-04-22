class Webhooks::BaseWebhookController < Webhooks::BaseController
  skip_before_filter :redirect_if_marketplace_password_protected
  before_filter :find_payment_gateway

  protected

  def find_payment_gateway
    @payment_gateway ||= payment_gateway_class.mode_scope.first!
  end

  def payment_gateway_class
    raise NotImplementedError
  end
end
