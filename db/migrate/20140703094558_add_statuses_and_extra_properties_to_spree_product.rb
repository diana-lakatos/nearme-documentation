class AddStatusesAndExtraPropertiesToSpreeProduct < ActiveRecord::Migration
  def up
    add_column :spree_products, :extra_properties, :hstore
    add_column :spree_products, :status, :hstore
    add_column :spree_products, :products_public, :boolean, default: true
    add_column :spree_products, :approved, :boolean, default: true

    execute "CREATE INDEX spree_products_gin_extra_properties ON spree_products USING GIN(extra_properties)"
  end

  def down
    remove_column :spree_products, :extra_properties
    remove_column :spree_products, :status
    remove_column :products_public, :products_public
    remove_column :spree_products, :approved, :boolean
  end
end
