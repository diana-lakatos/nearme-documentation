class AddDefaultValueToWorkplacesVenue < ActiveRecord::Migration
  def self.up
    change_column :workplaces, :fake, :boolean, :default => false, :null => false
  end

  def self.down
    change_column :workplaces, :fake, :boolean
  end
end
