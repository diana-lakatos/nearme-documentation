class AddEncryptedDbConnectionStringToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :encrypted_db_connection_string, :string
  end
end
