class OrderItemApprovalJob < Job
  def after_initialize(order_item_id)
    @order_item = RecurringBookingPeriod.find_by_id(order_item_id)
  end

  def perform
    @order_item.auto_approve!
  end
end
