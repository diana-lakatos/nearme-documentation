class EncryptExistingSensitiveColumns < ActiveRecord::Migration

  def change
    add_column :users, :encrypted_stripe_id, :string
    add_column :users, :encrypted_paypal_id, :string
    add_column :instances, :encrypted_stripe_api_key, :string
    add_column :charges, :encrypted_response, :string
    add_column :payouts, :encrypted_response, :string
  end

end
