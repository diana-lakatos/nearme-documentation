class AddPropertiesToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :properties, :hstore
    add_column :recurring_bookings, :properties, :hstore
  end
end
