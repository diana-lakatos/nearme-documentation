class AddShippoEnabledToSpreeProducts < ActiveRecord::Migration
  def change
    add_column :spree_products, :shippo_enabled, :boolean, :default => false
  end
end
