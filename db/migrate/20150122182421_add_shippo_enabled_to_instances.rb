class AddShippoEnabledToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :shippo_enabled, :boolean, :default => false
  end
end
