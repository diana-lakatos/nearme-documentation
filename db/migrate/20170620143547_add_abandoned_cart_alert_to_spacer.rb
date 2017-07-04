class AddAbandonedCartAlertToSpacer < ActiveRecord::Migration
  def up
    Instance.find_each do |instance|
      instance.set_context!
      Utils::DefaultAlertsCreator::OrderCreator.new.abandoned_cart_reminder!(enabled: false)
    end
    PlatformContext.clear_current
  end

  def down
    PlatformContext.clear_current
    WorkflowAlert.where(name: 'Abandoned cart').destroy_all
  end
end
