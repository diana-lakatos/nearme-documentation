class AddColumnsToRecurringBookingPeriods < ActiveRecord::Migration
  def change
    add_column :recurring_booking_periods, :ends_at, :datetime
    add_column :recurring_booking_periods, :starts_at, :datetime
  end
end
