class CreateMerchantAccounts < ActiveRecord::Migration
  def change
    create_table :merchant_accounts do |t|
      t.integer :instance_id
      t.integer :merchantable_id
      t.string :merchantable_type
      t.text :encrypted_response
      t.string :gateway_class
      t.boolean :enabled, default: false
      t.timestamps
    end
    add_index :merchant_accounts, [:instance_id, :merchantable_id, :merchantable_type], name: 'index_on_merchant_accounts_on_merchant'
  end
end
