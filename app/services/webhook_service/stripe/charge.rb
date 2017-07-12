# frozen_string_literal: true
module WebhookService
  module Stripe
    class Charge < WebhookService::Stripe::Event
      ALLOWED_EVENTS = %w{captured failed pending succeeded refunded updated}

      def parse_event!
        return false unless ALLOWED_EVENTS.map {|e| "transfer." + e }.include?(event.type)
        return false if payment.blank?

        PaymentReloaderService.new(payment, charge).process!
      end

      def charge
        if fetch_object?
          @charge ||= payment_gateway.find_payment(event.data.object.id, event.user_id)
        else
          @charge ||= Payment::Gateway::Response::Stripe::Charge.new(event.data.object)
        end
      end

      def payment
        @payment ||= payment_gateway.payments.find_by_external_id(event.data.object.id)
      end
    end
  end
end
