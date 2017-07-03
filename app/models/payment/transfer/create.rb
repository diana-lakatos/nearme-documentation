class Payment
  module Transfer
    class Create
      def initialize(payment_gateway, transfer_response, merchant_account=nil)
        @payment_gateway = payment_gateway
        @transfer_response = transfer_response
        @merchant_account = merchant_account
      end

      def process
        return unless can_process?

        payment_transfer = @payment_gateway.payment_transfers.create!(
          company: payments.first.company,
          payments: payments,
          payment_gateway_mode: @payment_gateway.mode,
          token: @transfer_response.id,
          merchant_account: @merchant_account
        )

        Payment::Transfer::Update.new(@payment_gateway, @transfer_response, payment_transfer).process
      end

      private

      def can_process?
        return false unless @payment_gateway.direct_charge?
        return false if payout_scope.any?
        return false if payments.blank? || payments.map(&:company_id).uniq.size != 1

        true
      end

      def charge_ids
        return [] if balance_charges_and_payments.blank?

        balance_charges_and_payments.map(&:source).compact.compact
      end

      def payments
        @payments ||= @payment_gateway.payments.where(external_id: charge_ids)
      end

      # We need to fetch both CreditCard charges_and_payments
      # and BankAccount payments
      def balance_charges_and_payments
        @payout_charges ||= balance.charges_and_payments
      end

      def payout_scope
        @payment_gateway.payment_transfers.with_token(@transfer_response.id).where(payment_gateway_mode: @payment_gateway.mode)
      end

      def balance
        @balance ||= @payment_gateway.find_transfer_transactions(
          @transfer_response.id, @merchant_account.try(:external_id)
        )
      end
    end
  end
end
