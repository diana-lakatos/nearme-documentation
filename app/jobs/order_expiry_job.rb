class OrderExpiryJob < Job
  def after_initialize(order_id)
    @order = Order.find_by_id(order_id)
  end

  def perform
    @order.try(:perform_expiry!)
  end
end
