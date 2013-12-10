class AddUnreadListingMessageThreadsCountToUsers < ActiveRecord::Migration

  def change
    add_column :users, :unread_listing_message_threads_count, :integer, default: 0
  end
end
