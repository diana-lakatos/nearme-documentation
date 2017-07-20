require 'stripe'

module Webhooks
  class StripeController < Webhooks::BaseWebhookController
    def webhook
      begin
        event
      rescue JSON::ParserError => e
        render(nothing: true, status: 400) && return
      rescue Stripe::SignatureVerificationError => e
        render(nothing: true, status: 400) && return
      end

      WebhookProcessorJob.perform(webhook_object.id)

      render nothing: true
    end

    private

    def webhook_configuration
      @webhook_configuration = WebhookConfiguration.find(params[:webhook_configuration_id])
    end

    def find_payment_gateway
      @payment_gateway ||= webhook_configuration.payment_gateway
    end

    def webhook_object
      @payment_gateway.webhooks.where(
         external_id: event.webhook_external_id
       ).first_or_create! do |w|
         w.response = event.to_yaml
       end
    end

    def event
      @event ||= Payment::Gateway::Response::Stripe::Event.new(
        Stripe::Webhook.construct_event(
          request.raw_post,
          request.headers['HTTP_STRIPE_SIGNATURE'],
          webhook_configuration.signing_secret
        )
      )
    end
  end
end
