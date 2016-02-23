class RenameReservationTypeToBookingTypeInReservations < ActiveRecord::Migration
  def change
    rename_column :reservations, :reservation_type, :booking_type
  end
end
