class AddGuestNotesToRecurringBookings < ActiveRecord::Migration
  def change
    add_column :recurring_bookings, :guest_notes, :text
  end
end
