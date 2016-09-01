class AddOrderItToRecurringBookingPeriods < ActiveRecord::Migration
  def change
    add_column :recurring_booking_periods, :order_id, :integer, index: true
    add_column :recurring_booking_periods, :comment, :text
    add_column :recurring_booking_periods, :state, :string

    RecurringBookingPeriod.reset_column_information
    RecurringBookingPeriod.update_all("order_id = recurring_booking_id")
  end
end
