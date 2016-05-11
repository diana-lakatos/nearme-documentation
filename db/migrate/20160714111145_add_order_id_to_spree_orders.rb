class AddOrderIdToSpreeOrders < ActiveRecord::Migration
  def change
    add_column :spree_orders, :order_id, :integer
  end
end
