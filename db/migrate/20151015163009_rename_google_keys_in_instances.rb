class RenameGoogleKeysInInstances < ActiveRecord::Migration
  def change
    rename_column :instances, :encrypted_google_oauth2_consumer_key, :encrypted_google_consumer_key
    rename_column :instances, :encrypted_google_oauth2_consumer_secret, :encrypted_google_consumer_secret
  end
end
