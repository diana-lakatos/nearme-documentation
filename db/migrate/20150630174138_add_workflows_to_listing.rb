class AddWorkflowsToListing < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      PlatformContext.current = PlatformContext.new(i)
      Utils::DefaultAlertsCreator::ListingCreator.new.create_rejected_email!
      Utils::DefaultAlertsCreator::ListingCreator.new.create_questioned_email!
    end
  end
end
