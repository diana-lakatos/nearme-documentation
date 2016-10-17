class OrderMarkAsArchivedJob < Job
  def after_initialize(order_id)
    @order = Order.find_by_id(order_id)
  end

  def perform
    @order.mark_as_archived! if @order.ends_at.present? && @order.ends_at > Time.now
  end
end
