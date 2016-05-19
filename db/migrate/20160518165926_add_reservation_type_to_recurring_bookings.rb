class AddReservationTypeToRecurringBookings < ActiveRecord::Migration
  def change
    add_column :recurring_bookings, :reservation_type_id, :integer
  end
end
