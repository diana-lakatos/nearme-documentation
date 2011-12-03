class RemoveDeltaFromWorkplaces < ActiveRecord::Migration
  def self.up
    remove_column :workplaces, :delta
  end

  def self.down
    add_column :workplaces, :delta, :boolean
  end
end
