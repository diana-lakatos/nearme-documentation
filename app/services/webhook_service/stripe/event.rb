module WebhookService
  module Stripe
    class Event
      attr_reader :event, :merchant_account, :payment_gateway

      def initialize(event, payment_gateway, merchant_account)
        @event = event
        @merchant_account = merchant_account
        @payment_gateway = payment_gateway
      end
    end
  end
end
