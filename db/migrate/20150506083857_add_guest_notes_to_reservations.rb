class AddGuestNotesToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :guest_notes, :text
  end
end
