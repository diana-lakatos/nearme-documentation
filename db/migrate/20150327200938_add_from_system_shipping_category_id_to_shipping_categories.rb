class AddFromSystemShippingCategoryIdToShippingCategories < ActiveRecord::Migration
  def change
    add_column :spree_shipping_categories, :from_system_shipping_category_id, :integer, index: true
  end
end
