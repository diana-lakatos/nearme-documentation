class AddUnreadUserMessageThreadsCountToUser < ActiveRecord::Migration
  def change
    add_column :users, :unread_user_message_threads_count, :integer, default: 0

    User.connection.execute("UPDATE users SET unread_user_message_threads_count = unread_listing_message_threads_count;")
  end
end
