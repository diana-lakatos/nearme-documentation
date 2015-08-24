class AddEncryptedShippoApiTokenToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :encrypted_shippo_api_token, :string
  end
end
