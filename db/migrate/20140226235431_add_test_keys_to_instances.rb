class AddTestKeysToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :password_protected,                  :boolean, :default => false
    add_column :instances, :test_mode,                           :boolean, :default => false
    add_column :instances, :encrypted_test_paypal_username,      :string
    add_column :instances, :encrypted_test_paypal_password,      :string
    add_column :instances, :encrypted_test_paypal_signature,     :string
    add_column :instances, :encrypted_test_paypal_app_id,        :string
    add_column :instances, :encrypted_test_paypal_client_id,     :string
    add_column :instances, :encrypted_test_paypal_client_secret, :string
    add_column :instances, :encrypted_test_stripe_api_key,       :string
    add_column :instances, :test_stripe_public_key,              :string
    add_column :instances, :encrypted_test_balanced_api_key,     :string

    rename_column :instances, :encrypted_paypal_username,      :encrypted_live_paypal_username
    rename_column :instances, :encrypted_paypal_password,      :encrypted_live_paypal_password
    rename_column :instances, :encrypted_paypal_signature,     :encrypted_live_paypal_signature
    rename_column :instances, :encrypted_paypal_app_id,        :encrypted_live_paypal_app_id
    rename_column :instances, :encrypted_paypal_client_id,     :encrypted_live_paypal_client_id
    rename_column :instances, :encrypted_paypal_client_secret, :encrypted_live_paypal_client_secret
    rename_column :instances, :encrypted_stripe_api_key,       :encrypted_live_stripe_api_key
    rename_column :instances, :stripe_public_key,              :live_stripe_public_key
    rename_column :instances, :encrypted_balanced_api_key,     :encrypted_live_balanced_api_key
  end
end
