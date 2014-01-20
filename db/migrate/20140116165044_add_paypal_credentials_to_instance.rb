class AddPaypalCredentialsToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :encrypted_paypal_username, :string
    add_column :instances, :encrypted_paypal_password, :string
    add_column :instances, :encrypted_paypal_signature, :string
    add_column :instances, :encrypted_paypal_app_id, :string
    add_column :instances, :encrypted_paypal_client_id, :string
    add_column :instances, :encrypted_paypal_client_secret, :string
  end
end
