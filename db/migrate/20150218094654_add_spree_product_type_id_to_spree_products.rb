class AddSpreeProductTypeIdToSpreeProducts < ActiveRecord::Migration
  def change
    add_column :spree_products, :product_type_id, :integer
    add_index :spree_products, :product_type_id
  end
end
