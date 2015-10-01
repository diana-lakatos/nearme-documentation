class AddGoogleGithubProviderKeysToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :encrypted_github_consumer_key, :string, limit: 255
    add_column :instances, :encrypted_github_consumer_secret, :string, limit: 255
    add_column :instances, :encrypted_google_oauth2_consumer_key, :string, limit: 255
    add_column :instances, :encrypted_google_oauth2_consumer_secret, :string, limit: 255
  end
end
