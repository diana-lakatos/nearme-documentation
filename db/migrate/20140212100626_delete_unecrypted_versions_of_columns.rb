class DeleteUnecryptedVersionsOfColumns < ActiveRecord::Migration
  def up
    remove_column :charges, :response
    remove_column :instances, :stripe_api_key
    remove_column :users, :stripe_id
    remove_column :users, :paypal_id
    # we moved them to InstanceClient table, to allow multiple stripe/paypal/balanced ids [ one per instance ]
    remove_column :users, :encrypted_stripe_id
    remove_column :users, :encrypted_paypal_id
    remove_column :users, :encrypted_balanced_user_id
    remove_column :users, :encrypted_balanced_credit_card_id
  end

  def down
    add_column :charges, :response, :text
    add_column :instances, :stripe_api_key, :string
    add_column :users, :stripe_id, :string
    add_column :users, :paypal_id, :string
    add_column :users, :encrypted_stripe_id, :string
    add_column :users, :encrypted_paypal_id, :string
    add_column :users, :encrypted_balanced_user_id, :string
    add_column :users, :encrypted_balanced_credit_card_id, :string
  end
end
