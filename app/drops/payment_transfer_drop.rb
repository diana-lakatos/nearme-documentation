# frozen_string_literal: true
class PaymentTransferDrop < BaseDrop

  # @!method id
  #   @return [Integer] numeric identifier for the payment transfer
  # @!method amount
  #   @return [MoneyDrop] total amount for this payment transfer
  # @!method created_at
  #   @return [DateTime] when the payment transfer was initiated
  # @!method transfer_status
  #   @return [String] transfer status for this payment (i.e. pending, failed, transferred or n/a)
  # @!method total_service_fee
  #   @return [MoneyDrop] service fee guest + service fee host related to this transfer
  # @!method payment_gateway_fee
  #   @return [MoneyDrop] payment gateway fee related to this transfer
  # @!method gross_amount
  #   @return [MoneyDrop] gross amount for the payment transfer (amount + total_service_fee + payment_gateway_fee)
  delegate :amount, :created_at, :transfer_status, :total_service_fee, :payment_gateway_fee,
           :gross_amount, :id, to: :@source

  def initialize(source)
    @source = source.decorate
  end
end
