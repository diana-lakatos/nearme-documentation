class AddIsFreeBookingToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :is_free_booking, :boolean, default: false
  end
end
