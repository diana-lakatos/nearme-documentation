class CreateInstanceClients < ActiveRecord::Migration
  def change
    create_table :instance_clients do |t|
      t.references :client, :polymorphic => true
      t.references :instance, :index => true
      t.string :encrypted_stripe_id
      t.string :encrypted_paypal_id
      t.string :encrypted_balanced_user_id
      t.string :encrypted_balanced_credit_card_id
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
