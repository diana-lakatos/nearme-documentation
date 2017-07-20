# frozen_string_literal: true
module WebhookService
  module Stripe
    class Transfer < WebhookService::Stripe::Event
      ALLOWED_EVENTS = %w(created paid failed updated).freeze

      def parse_event!
        return false unless ALLOWED_EVENTS.map { |e| 'transfer.' + e }.include?(event.type)

        'transfer.created' == event.type ? transfer_created : transfer_updated
      end

      private

      # Please not that transfer.created webhook should only be set
      # when using direct payments, otherwise transfer is created (with proper id)
      # with payment and only transfer.updated webhook should be configured.
      def transfer_created
        Payment::Transfer::Create.new(payment_gateway, transfer, merchant_account).process
      end

      # Transfer updated webhook is fired when money is moved from MPO stripe account
      # to connected account. If you want to update PaymentTransfer object when money
      # is actually send to Merchant bank account use payout.updated webhook.
      def transfer_updated
        Payment::Transfer::UpdateCollection.new(payment_gateway, transfer, [transfer.id]).process
      end

      def transfer
        if fetch_object?
          @transfer ||= @payment_gateway.retrieve_transfer(event.data.object, event.user_id)
        else
          @transfer ||= wrapper_class.new(event.data.object)
        end
      end

      def wrapper_class
        Payment::Gateway::Response::Stripe::Transfer
      end
    end
  end
end
