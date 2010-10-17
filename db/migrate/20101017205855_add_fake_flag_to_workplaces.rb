class AddFakeFlagToWorkplaces < ActiveRecord::Migration
  def self.up
    add_column :workplaces, :fake, :boolean
  end

  def self.down
    remove_column :workplaces, :fake
  end
end
