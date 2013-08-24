class AddGoogleAnalyticsIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :google_analytics_id, :string, :default => nil
  end
end
