class AddExpiresAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :expires_at, :datetime, default: nil
  end
end
