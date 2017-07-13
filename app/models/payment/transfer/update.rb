class Payment
  module Transfer
    class Update
      def initialize(payment_gateway, transfer_response, payment_transfer)
        @payment_gateway = payment_gateway
        @transfer_response = transfer_response
        @payment_transfer = payment_transfer
      end

      def process
        if @transfer_response.paid?
          @payment_transfer.payout_attempts.last.payout_successful(@transfer_response)
        elsif @transfer_response.failed?
          @payment_transfer.payout_attempts.last.payout_failed(@transfer_response)
        end
      end
    end
  end
end
