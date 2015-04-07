class AddIsSystemProfileToShippingCategories < ActiveRecord::Migration
  def change
    add_column :spree_shipping_categories, :is_system_profile, :boolean, :default => false
  end
end
