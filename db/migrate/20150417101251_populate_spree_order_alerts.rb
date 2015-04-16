class PopulateSpreeOrderAlerts < ActiveRecord::Migration

  def up
    Instance.find_each do |i|
      puts "Creating spree order alerts for #{i.name}"
      PlatformContext.current = PlatformContext.new(i)
      Utils::DefaultAlertsCreator::OrderCreator.new.create_all!
    end
  end

  def down

  end
end
