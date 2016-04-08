class AddWorkflowsForInappropriateReported < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      PlatformContext.current = PlatformContext.new(i)
      # rescue added for test environment ;)
      Utils::DefaultAlertsCreator::ListingCreator.new.create_inappropriated_email! rescue puts "Failed to create inappropriated email for #{i.name}"
    end
  end
end
