class AddMaintenanceModeToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :maintenance_mode, :boolean, default: false
  end
end
