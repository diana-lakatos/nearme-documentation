class AddAuthenticationFieldsFromApi < ActiveRecord::Migration
  def self.up
    add_column :authentications, :deleted_at, :datetime
    add_column :authentications, :secret, :string
    add_column :authentications, :token, :string
    add_column :authentications, :info, :text

    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :confirmed_at, :datetime
    add_column :users, :deleted_at, :datetime
    add_column :users, :locked_at, :datetime
    # add_column :users, :reset_password_sent_at, :datetime
    add_column :users, :failed_attempts, :integer, :default => 0
    add_column :users, :authentication_token, :string
    add_column :users, :avatar, :string
    add_column :users, :confirmation_token, :string
    add_column :users, :phone, :string
    add_column :users, :unconfirmed_email, :string
    add_column :users, :unlock_token, :string
  end

  def self.down
    remove_column :users, :unlock_token
    remove_column :users, :unconfirmed_email
    remove_column :users, :phone
    remove_column :users, :confirmation_token
    remove_column :users, :avatar
    remove_column :users, :authentication_token
    remove_column :users, :failed_attempts
    # remove_column :users, :reset_password_sent_at
    remove_column :users, :locked_at
    remove_column :users, :deleted_at
    remove_column :users, :confirmed_at
    remove_column :users, :confirmation_sent_at

    remove_column :authentications, :info
    remove_column :authentications, :token
    remove_column :authentications, :secret
    remove_column :authentications, :deleted_at
  end
end
