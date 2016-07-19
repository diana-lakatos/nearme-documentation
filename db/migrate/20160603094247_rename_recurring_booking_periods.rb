class RenameRecurringBookingPeriods < ActiveRecord::Migration
  def change
    rename_table :recurring_booking_periods, :old_recurring_booking_periods

    create_table "recurring_booking_periods", force: :cascade do |t|
      t.integer  "recurring_booking_id"
      t.integer  "instance_id",                    null: false
      t.date     "period_start_date"
      t.date     "period_end_date"
      t.integer  "subtotal_amount_cents"
      t.integer  "service_fee_amount_guest_cents"
      t.integer  "service_fee_amount_host_cents"
      t.integer  "credit_card_id"
      t.string   "currency"
      t.datetime "deleted_at"
      t.datetime "paid_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
