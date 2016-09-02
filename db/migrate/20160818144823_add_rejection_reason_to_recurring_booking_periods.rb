class AddRejectionReasonToRecurringBookingPeriods < ActiveRecord::Migration
  def change
    add_column :recurring_booking_periods, :rejection_reason, :text
  end
end
