class DropListingMessages < ActiveRecord::Migration
  def up
    drop_table :listing_messages
    remove_column :users, :unread_listing_message_threads_count
  end

  def down
  end
end
