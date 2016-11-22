# frozen_string_literal: true
class PaymentTransferDrop < BaseDrop
  delegate :amount, :created_at, :transfer_status, :total_service_fee, :payment_gateway_fee,
           :gross_amount, :id, to: :@source

  def initialize(source)
    @source = source.decorate
  end
end
