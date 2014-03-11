class AddSocialAuthKeysToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :encrypted_facebook_consumer_key, :string
    add_column :instances, :encrypted_facebook_consumer_secret, :string

    add_column :instances, :encrypted_linkedin_consumer_key, :string
    add_column :instances, :encrypted_linkedin_consumer_secret, :string

    add_column :instances, :encrypted_twitter_consumer_key, :string
    add_column :instances, :encrypted_twitter_consumer_secret, :string

    add_column :instances, :encrypted_instagram_consumer_key, :string
    add_column :instances, :encrypted_instagram_consumer_secret, :string
  end
end
