class AddReservationTypeToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :reservation_type, :string
  end
end
