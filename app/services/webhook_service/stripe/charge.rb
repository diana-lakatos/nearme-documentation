module WebhookService
  module Stripe
    class Charge < WebhookService::Stripe::Event
      ALLOWED_EVENTS = %w{captured failed pending succeeded refunded updated}

      def parse_event!
        return false unless ALLOWED_EVENTS.map {|e| "transfer." + e }.include?(event.type)
        return false if payment.blank?

        PaymentReloaderService.new(payment, payment_response).process!
      end

      def payment_response
        PaymentGateway::Response::Stripe::Payment.new(event.data.object)
      end

      def payment
        @account ||= payment_gateway.payments.find_by_external_id(event.data.object.id)
      end
    end
  end
end
