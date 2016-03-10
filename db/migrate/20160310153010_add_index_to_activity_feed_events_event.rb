class AddIndexToActivityFeedEventsEvent < ActiveRecord::Migration
  def change
    add_index :activity_feed_events, :event
  end
end
