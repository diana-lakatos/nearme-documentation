class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.integer :instance_id
      t.timestamp :deleted_at
      t.string :token
      t.datetime :expires_at
    end
    add_index :api_keys, [:instance_id, :token], unique: true
  end
end
