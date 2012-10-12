class AddDefaultLocationAvailability < ActiveRecord::Migration
  class Location < ActiveRecord::Base
  end

  class AvailabilityRule < ActiveRecord::Base
  end

  def up
    Location.find_each do |location|
      existing_rules = AvailabilityRule.where(:target_type => "Location", :target_id => location.id)
      next if existing_rules.any?

      # Create all rules for M-F9-5
      (1..5).each do |wday|
        AvailabilityRule.create!(
          :target_type => "Location",
          :target_id => location.id,
          :day => wday, :open_hour => 9, :open_minute => 0, :close_hour => 17, :close_minute => 0
        )
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
