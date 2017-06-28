class GenerateOrderItemsJob < Job
  def perform
    return true unless Rails.env.production?

    Order.needs_new_order_item(Time.current).find_each do |order|
      GenerateOrderItemJob.perform(order.id)
    end
  end
end
