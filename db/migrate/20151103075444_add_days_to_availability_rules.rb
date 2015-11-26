class AddDaysToAvailabilityRules < ActiveRecord::Migration
  def change
    add_column :availability_rules, :days, :integer, array: true, default: []
  end
end
