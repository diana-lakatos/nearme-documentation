class AddShoppingCartIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :shopping_cart_id, :integer, index: true
  end
end
