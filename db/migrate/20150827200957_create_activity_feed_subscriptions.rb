class CreateActivityFeedSubscriptions < ActiveRecord::Migration
  def change
    create_table :activity_feed_subscriptions do |t|
      t.integer :instance_id

      t.integer :follower_id
      t.string :follower_type
      t.integer :followed_id
      t.string :followed_type

      t.string :followed_identifier

      t.timestamps
    end

    add_index :activity_feed_subscriptions, [:instance_id, :follower_id, :follower_type], name: :activity_feed_subscriptions_instance_follower
    add_index :activity_feed_subscriptions, [:instance_id, :followed_id, :followed_type], name: :activity_feed_subscriptions_instance_followed
  end
end
