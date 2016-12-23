class AddApproveAtToRecurringBookingPeriods < ActiveRecord::Migration
  def change
    add_column :recurring_booking_periods, :approve_at, :timestamp
  end
end
