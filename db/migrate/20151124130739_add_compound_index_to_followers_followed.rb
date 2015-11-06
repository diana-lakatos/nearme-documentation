class AddCompoundIndexToFollowersFollowed < ActiveRecord::Migration
  def up
    ActivityFeedSubscription.unscoped.find_each do |afs|
      afs.valid? ? next : afs.destroy
    end

    add_index :activity_feed_subscriptions, [:follower_id, :followed_id, :followed_type], name: 'afs_followers_followed', unique: true
  end

  def down
    remove_index :activity_feed_subscriptions, [:follower_id, :followed_id, :followed_type], name: 'afs_followers_followed'
  end
end
