class AddOrderItToRecurringBookings < ActiveRecord::Migration
  def change
    add_column :recurring_bookings, :order_id, :integer
  end
end
