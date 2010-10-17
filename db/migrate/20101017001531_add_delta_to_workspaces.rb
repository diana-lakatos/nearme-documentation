class AddDeltaToWorkspaces < ActiveRecord::Migration
  def self.up
    add_column :workplaces, :delta, :boolean, :default => true, :null => false
  end

  def self.down
  end
end
