class AddExclusiveToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :exclusive_price, :boolean
    add_column :orders, :book_it_out, :boolean
  end
end
