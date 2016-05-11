class AddCompletedAtToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :completed_at, :timestamp
  end
end
