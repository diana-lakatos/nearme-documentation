class AddPendingGuestConfirmationToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :pending_guest_confirmation, :datetime
  end
end
