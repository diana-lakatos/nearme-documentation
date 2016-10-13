class AddPurchaseWorkflowAlerts < ActiveRecord::Migration
  def self.up
    Instance.find_each do |i|
      PlatformContext.current = PlatformContext.new(i)
      Utils::DefaultAlertsCreator::PurchaseCreator.new.create_all!
    end
  end

  def self.down
  end
end
