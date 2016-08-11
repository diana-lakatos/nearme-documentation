class RenameUnusedRecurringBookingPeriodColumns < ActiveRecord::Migration
  def change
    rename_column :recurring_booking_periods, :subtotal_amount_cents, :old_subtotal_amount_cents
    rename_column :recurring_booking_periods, :service_fee_amount_host_cents, :old_service_fee_amount_host_cents
    rename_column :recurring_booking_periods, :service_fee_amount_guest_cents, :old_service_fee_amount_guest_cents
  end
end
