class CreateRecurringBookings < ActiveRecord::Migration
  def change
    create_table :recurring_bookings do |t|
      t.integer  :transactable_id
      t.integer  :owner_id
      t.integer  :creator_id
      t.integer  :administrator_id
      t.integer  :company_id
      t.integer  :partner_id
      t.integer  :instance_id
      t.boolean  :listings_public
      t.datetime :deleted_at
      t.datetime :start_on
      t.datetime :end_on
      t.integer :quantity
      t.integer  :start_minute
      t.integer  :end_minute
      t.text :schedule_params
      t.string :state
      t.string :currency
      t.string :payment_method, null: false, default: 'manual'
      t.integer :platform_context_detail_id
      t.string :platform_context_detail_type
      t.integer  :service_fee_amount_guest_cents, default: 0, null: false
      t.integer  :service_fee_amount_host_cents, default: 0, null: false
      t.integer  :subtotal_amount_cents
      t.string   :rejection_reason
      t.timestamps
    end
    add_index :recurring_bookings, :transactable_id
    add_index :recurring_bookings, :owner_id
    add_index :recurring_bookings, :creator_id
    add_index :recurring_bookings, :administrator_id
    add_index :recurring_bookings, :instance_id
    add_index :recurring_bookings, :company_id

    add_column :reservations, :recurring_booking_id, :integer
    add_index :reservations, :recurring_booking_id

    add_column :transactable_types, :recurring_booking, :boolean, null: false, default: false
  end
end
