class SupportRecurringPayment < ActiveRecord::Migration
  def up
    add_column :reservation_charges, :recurring_booking_error, :text
    add_column :instance_clients, :gateway_class, :string
    add_column :instance_clients, :encrypted_response, :text
    add_column :reservations, :credit_card_id, :integer
    add_column :recurring_bookings, :credit_card_id, :integer
    add_column :recurring_bookings, :hours_before_reservation_to_charge, :integer, default: 24
    remove_column :instance_clients, :encrypted_stripe_id
    remove_column :instance_clients, :encrypted_paypal_id
    remove_column :instance_clients, :encrypted_balanced_credit_card_id

    create_table :credit_cards do |t|
      t.integer  :instance_client_id
      t.integer  :instance_id
      t.datetime :deleted_at
      t.string :gateway_class
      t.text :encrypted_response
      t.boolean :default_card
      t.timestamps
    end
    add_index :credit_cards, :instance_id
    add_index :credit_cards, :instance_client_id
  end

  def down
    remove_column :reservation_charges, :recurring_booking_error
    remove_column :instance_clients, :gateway_class
    remove_column :instance_clients, :encrypted_response
    remove_column :reservations, :credit_card_id
    remove_column :recurring_bookings, :credit_card_id
    remove_column :recurring_bookings, :hours_before_reservation_to_charge
    add_column :instance_clients, :encrypted_stripe_id, :string
    add_column :instance_clients, :encrypted_paypal_id, :string
    add_column :instance_clients, :encrypted_balanced_credit_card_id, :string
    drop_table :credit_cards
  end
end
