require 'braintree'

class Webhooks::BraintreeMarketplacesController < Webhooks::BaseWebhookController
  def webhook
    webhook = @payment_gateway.webhooks.where(response: params.to_yaml).create!
    webhook.process!
    render nothing: true
  end

  protected

  def payment_gateway_class
    PaymentGateway::BraintreeMarketplacePaymentGateway
  end
end
