class AddIntervalToRecurringBooking < ActiveRecord::Migration
  def up
    add_column :recurring_bookings, :interval, :string
    add_column :recurring_bookings, :paid_until, :date
    add_column :recurring_bookings, :next_charge_date, :date
    add_column :recurring_bookings, :payment_gateway_id, :integer
    add_column :recurring_bookings, :test_mode, :string
  end

  def down
    remove_column :recurring_bookings, :interval
    remove_column :recurring_bookings, :paid_until
    remove_column :recurring_bookings, :next_charge_date
    remove_column :recurring_bookings, :payment_gateway_id
    remove_column :recurring_bookings, :test_mode
  end

end
