class CreateActivityFeedEvents < ActiveRecord::Migration
  def change
    create_table :activity_feed_events do |t|
      t.integer :instance_id
      t.string :event

      t.integer :followed_id
      t.string :followed_type

      t.text :affected_objects_identifiers, array: true, default: []

      t.timestamps
    end

    add_index :activity_feed_events, [:instance_id, :followed_id, :followed_type], name: :activity_feed_events_instance_followed
  end
end
