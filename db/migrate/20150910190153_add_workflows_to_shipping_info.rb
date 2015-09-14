class AddWorkflowsToShippingInfo < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      PlatformContext.current = PlatformContext.new(i)
      Utils::DefaultAlertsCreator::OrderCreator.new.create_notify_buyer_of_shipping_info_email!
      Utils::DefaultAlertsCreator::OrderCreator.new.create_notify_seller_of_shipping_info_email!
    end
  end
end
