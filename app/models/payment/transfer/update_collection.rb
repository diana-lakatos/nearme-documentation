class Payment
  module Transfer
    class UpdateCollection

      def initialize(payment_gateway, transfer_response, payment_transfer_external_ids)
        @payment_gateway = payment_gateway
        @transfer_response = transfer_response
        @payment_transfer_external_ids = payment_transfer_external_ids
      end

      def process
        find_payment_transfers.each do |payment_transfer|
          Payment::Transfer::Update.new(@payment_gateway, @transfer_response, payment_transfer).process
        end
      end

      def find_payment_transfers
        @payment_gateway.payment_transfers.with_tokens(@payment_transfer_external_ids)
      end
    end
  end
end
