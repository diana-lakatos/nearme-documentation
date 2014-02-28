class AddOlarkApiKeyToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :encrypted_olark_api_key, :string
    add_column :instances, :olark_enabled, :boolean, default: false
  end
end
