class AddIsSystemCategoryEnabledToShippingCategories < ActiveRecord::Migration
  def change
    add_column :spree_shipping_categories, :is_system_category_enabled, :boolean, default: true
  end
end
