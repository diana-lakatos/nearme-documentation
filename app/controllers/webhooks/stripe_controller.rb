module Webhooks
  class StripeController < Webhooks::BaseWebhookController
    def webhook
      webhook = @payment_gateway.webhooks.where(
        external_id: external_id
      ).first_or_create! do |w|
        w.response = params.to_yaml
      end
      webhook.process!
      render nothing: true
    end

    def external_id
      [params[:id], params[:user_id]].join('/')
    end

    def payment_gateway_class
      PaymentGateway::StripeConnectPaymentGateway
    end
  end
end
