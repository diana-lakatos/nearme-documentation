class CreateRecurringBookingPeriod < ActiveRecord::Migration
  def change
    create_table :recurring_booking_periods do |t|
      t.integer :recurring_booking_id
      t.integer :instance_id, index: true, null: false
      t.date :period_start_date
      t.date :period_end_date
      t.integer :subtotal_amount_cents
      t.integer :service_fee_amount_guest_cents
      t.integer :service_fee_amount_host_cents
      t.integer :credit_card_id, index: true
      t.string :currency
      t.datetime :deleted_at, default: nil
      t.datetime :paid_at, default: nil
      t.timestamps
      t.index [:recurring_booking_id, :period_start_date, :period_end_date], unique: true, name: 'index_recurring_booking_periods_on_fk_and_dates'
    end
  end
end
