class CreatePaypalAccounts < ActiveRecord::Migration
  def change
    create_table :paypal_accounts do |t|
      t.string :email
      t.integer :instance_id, null: false
      t.integer :instance_client_id
      t.integer :deleted_at
      t.integer :encrypted_response
      t.integer  :payment_gateway_id
      t.integer  :payment_method_id
      t.boolean  :test_mode, default: true
      t.string  :express_payer_id
      t.string  :encrypted_response
    end
  end
end
