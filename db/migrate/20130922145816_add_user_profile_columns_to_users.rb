class AddUserProfileColumnsToUsers < ActiveRecord::Migration

  class User < ActiveRecord::Base
    extend FriendlyId
    friendly_id :name, use: :slugged
  end

  def change
    # new columns
    add_column :users, :current_location, :text
    add_column :users, :company_name, :text
    add_column :users, :skills_and_interests, :text
    add_column :users, :facebook_url, :text
    add_column :users, :twitter_url, :text
    add_column :users, :linkedin_url, :text
    add_column :users, :instagram_url, :text

    # friendly_id
    add_column :users, :slug, :string
    add_index :users, :slug, unique: true
    User.find_each(&:save)
  end
end
