class AddRfqToProductsAndProductTypes < ActiveRecord::Migration
  def change
    add_column :spree_product_types, :action_rfq, :boolean
    add_column :spree_products, :action_rfq, :boolean
  end
end
