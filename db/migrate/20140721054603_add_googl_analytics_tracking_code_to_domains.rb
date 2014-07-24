class AddGooglAnalyticsTrackingCodeToDomains < ActiveRecord::Migration
  def change
    add_column :domains, :google_analytics_tracking_code, :string
  end
end
