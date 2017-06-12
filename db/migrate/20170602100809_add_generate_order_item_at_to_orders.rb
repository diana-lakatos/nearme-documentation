class AddGenerateOrderItemAtToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :generate_order_item_at, :timestamp
  end
end
