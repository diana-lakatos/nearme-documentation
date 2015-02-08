class GenerateOrderWorkflows < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      PlatformContext.current = PlatformContext.new(i)
      Utils::DefaultAlertsCreator::LineItemCreator.new.create_all!
    end
  end

  def down
  end
end
