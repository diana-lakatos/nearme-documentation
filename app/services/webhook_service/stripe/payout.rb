# frozen_string_literal: true
module WebhookService
  module Stripe
    class Payout < WebhookService::Stripe::Event
      ALLOWED_EVENTS = %w(created paid failed updated).freeze

      def parse_event!
        return false unless ALLOWED_EVENTS.map { |e| 'payout.' + e }.include?(event.type)

        'payout.created' == event.type ? payout_created : payout_updated
      end

      private

      def payout_created
        payment_transfer = Payment::Transfer::Create.new(payment_gateway, payout, merchant_account).process
      end

      def payout_updated
        Payment::Transfer::UpdateCollection.new(payment_gateway, payout, transfer_external_ids).process
      end

      def payout
        if fetch_object?
          @payout ||= @payment_gateway.retrieve_payout(event.data.object, event.user_id)
        else
          @payout ||= Payment::Gateway::Response::Stripe::Payout.new(event.data.object)
        end
      end

      # As we are on connected account we need to fetch transfers from
      # main Stripe account
      def transfer_external_ids
        @transfer_external_ids ||= if payment_gateway.direct_charge? && merchant_account
          # When webhook is sent to direct charge. We can assume that
          # PaymentTransfer external id was created with create webhook
          [payout.id]
        else
          balance.payments.map do |payment|
            payment_gateway.find_payment(payment.source, stripe_account: merchant_account.try(:external_id)).source_transfer
          end
        end
      end

      def balance
        @balance ||= payment_gateway.find_transfer_transactions(
          payout.id, merchant_account.try(:external_id)
        )
      end
    end
  end
end
