class ChangeFollowerToUserInActivityFeedSubscriptions < ActiveRecord::Migration
  def up
    remove_column :activity_feed_subscriptions, :follower_type
  end

  def down
    add_column :activity_feed_subscriptions, :follower_type, :string
    connection.execute <<-SQL
      UPDATE activity_feed_subscriptions
      SET
        follower_type = 'User'
    SQL
  end
end
