class AddMailchimpColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :mailchimp_synchronized_at, :timestamp
    add_column :users, :verified, :boolean, :default => false
  end
end
