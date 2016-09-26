class AddGoogleMapsApiKeyToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :encrypted_google_maps_api_key, :string, null: false, default: ''
  end
end
