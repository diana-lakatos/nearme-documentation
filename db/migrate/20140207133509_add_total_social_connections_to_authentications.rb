class AddTotalSocialConnectionsToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :total_social_connections, :integer, default: 0
  end
end
