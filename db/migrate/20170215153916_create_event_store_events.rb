# frozen_string_literal: true
class CreateEventStoreEvents < ActiveRecord::Migration
  def change
    create_table :event_store_events do |t|
      t.integer 'instance_id', null: false
      t.integer 'triggered_by_id'
      t.string :event_type, null: false
      t.string :topic_name
      t.text :payload

      t.timestamps null: false
    end

    add_index :event_store_events, [:instance_id, :event_type]
  end
end
