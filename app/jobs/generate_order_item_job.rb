# frozen_string_literal: true
class GenerateOrderItemJob < Job
  def after_initialize(order_id)
    @order_id = order_id
  end

  def perform
    order = Order.find(@order_id)
    order.instance.set_context!

    Order::OrderItemCreator.new(order).create
  end
end
