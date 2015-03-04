class AddDefaultCategoryFieldToShippingCategories < ActiveRecord::Migration
  def change
    add_column :spree_shipping_categories, :company_default, :boolean, :default => false
  end
end
