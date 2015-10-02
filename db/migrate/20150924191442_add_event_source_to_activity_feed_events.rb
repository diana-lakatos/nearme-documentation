class AddEventSourceToActivityFeedEvents < ActiveRecord::Migration
  def change
    add_column :activity_feed_events, :event_source_id, :integer
    add_column :activity_feed_events, :event_source_type, :string
  end
end
