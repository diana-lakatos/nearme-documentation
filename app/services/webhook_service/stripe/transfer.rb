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

      def transfer_created
        return if transfer_scope.any?
        return if (payments = find_transfer_payments).blank?
        return if (company = payments.first.company).blank?
        return if payments.map(&:company_id).uniq.size != 1

        transfer = payment_gateway.payment_transfers.create!(
          company: company,
          payments: payments,
          payment_gateway_mode: payment_gateway.mode,
          token: transfer_response.id,
          merchant_account: merchant_account
        )

        update_transfer(payment_transfer)
      end

      def transfer_updated
        update_transfer(payment_transfer)
      end

      def update_transfer(transfer)
        if transfer_response.paid?
          transfer.payout_attempts.last.payout_successful(event)
        elsif transfer_response.failed?
          transfer.payout_attempts.last.payout_failed(event)
        end
      end

      def transfer_response
        @transfer_response ||= PaymentGateway::Response::Stripe::Transfer.new(event.data.object)
      end

      def transfer_scope
        payment_gateway.payment_transfers.with_token(transfer_response.id).where(payment_gateway_mode: payment_gateway.mode)
      end

      def find_transfer_payments
        return if transfer_charges.blank?
        charge_ids = transfer_charges.map(&:source).compact
        payment_gateway.payments.where(external_id: charge_ids)
      end

      def payment_transfer
        @payment_transfer ||= transfer_scope.pending.first!
      end

      def transfer_transactions
        @transfer_transactions ||= payment_gateway.find_transfer_transactions(
          transfer_response.id, merchant_account.try(:external_id)
        ).try(:data)
      end

      def transfer_charges
        @transfer_charges ||= transfer_transactions.select { |t| t.type == 'charge' }
      end
    end
  end
end
