class AddHourlyReservationsToListings < ActiveRecord::Migration
  def change
    add_column :listings, :hourly_reservations, :boolean, :null => false, :default => false
    add_column :listings, :hourly_price_cents, :integer
    add_column :listings, :minimum_booking_minutes, :integer
  end
end
