class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.integer  "instance_client_id"
      t.integer  "instance_id",                                   null: false
      t.datetime "deleted_at"
      t.text     "encrypted_response"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "payment_gateway_id"
      t.integer  "payment_method_id"
      t.boolean  "test_mode",                      default: true
      t.string   "last4"
      t.string   "status"
      t.string   "bank_name"
      t.string   "encrypted_external_id"
    end
  end
end
