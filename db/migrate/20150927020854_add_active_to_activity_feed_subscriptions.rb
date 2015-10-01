class AddActiveToActivityFeedSubscriptions < ActiveRecord::Migration
  def change
    add_column :activity_feed_subscriptions, :active, :boolean, default: true
  end
end
