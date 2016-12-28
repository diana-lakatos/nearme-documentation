class SyncDeliveryStateJob < Job
  include Job::HighPriority

  def after_initialize(order_id)
    @order = Order.find(order_id)
  end

  def perform
    Deliveries::SyncOrderDeliveries.new(@order).perform
  end
end
