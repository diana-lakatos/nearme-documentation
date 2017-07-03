module WebhookService
  module Stripe
    class Event
      attr_reader :event, :merchant_account, :payment_gateway

      def initialize(event, payment_gateway, merchant_account, fetch_object)
        @event = event
        @merchant_account = merchant_account
        @payment_gateway = payment_gateway
        @fetch_object = fetch_object
      end

      def fetch_object?
        @fetch_object
      end
    end
  end
end
