class AddOrderIdToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :order_id, :integer
  end
end
