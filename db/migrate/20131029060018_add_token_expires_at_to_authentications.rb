class AddTokenExpiresAtToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :token_expires_at, :datetime
  end
end
