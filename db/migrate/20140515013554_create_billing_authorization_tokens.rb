class CreateBillingAuthorizationTokens < ActiveRecord::Migration
  def change
    create_table :billing_authorizations do |t|
      t.integer :instance_id
      t.integer :reservation_id
      t.string :encrypted_token
      t.string :encrypted_payment_gateway_class
      t.timestamps
    end
  end
end
