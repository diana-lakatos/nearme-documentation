class AddEncryptedShippoUsernameAndPasswordToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :encrypted_shippo_username, :string
    add_column :instances, :encrypted_shippo_password, :string
  end
end
