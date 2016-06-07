class AddFlagsToActivityFeedEvents < ActiveRecord::Migration
  def change
    add_column :activity_feed_events, :flags, :hstore, null: false, default: ''
  end
end
