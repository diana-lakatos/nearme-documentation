class CreatePaymentSubscriptions < ActiveRecord::Migration
  def change
    create_table :payment_subscriptions do |t|
      t.integer :payment_method_id
      t.integer :payment_gateway_id
      t.integer :credit_card_id
      t.integer :instance_id
      t.integer :company_id
      t.integer :partner_id
      t.integer :subscriber_id
      t.boolean :test_mode
      t.datetime :deleted_at
      t.string :subscriber_type

      t.timestamps null: false
    end

    add_index :payment_subscriptions, :company_id
    add_index :payment_subscriptions, :instance_id
    add_index :payment_subscriptions, :partner_id
    add_index :payment_subscriptions, [:subscriber_id, :subscriber_type], name: :subscriber_index
    add_index :payment_subscriptions, :payment_method_id
  end
end
