# frozen_string_literal: true
class ChargeCancellationPenaltyJob < Job
  def after_initialize(order_id, amount)
    @order_id = order_id
    @amount = amount
  end

  def perform
    order = Order.find(@order_id)
    OrderCancellationPenaltyService.new(order).charge!
  end
end
