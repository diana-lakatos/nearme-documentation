class AddExpiredAndExpiresToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :token_expired, :boolean, default: true
    add_column :authentications, :token_expires, :boolean, default: true
  end
end
