class AddOrderIdToShippingMethod < ActiveRecord::Migration
  def change
    add_column :spree_shipping_methods, :order_id, :integer

    add_index :spree_shipping_methods, :order_id
  end
end
