class AddOccurrencesAndChangeStartOnendOnInRecurringBookings < ActiveRecord::Migration
  def change
    add_column :recurring_bookings, :occurrences, :integer
    change_column :recurring_bookings, :start_on, :date
    change_column :recurring_bookings, :end_on, :date
  end
end
