class AddUnreadListingMessageThreadsCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :unread_listing_message_threads_count, :integer, default: 0
    User.all.each do |user|
      next if user.listing_messages.blank?
      actual_count = user.decorate.unread_listing_message_threads.fetch.size
      user.update_column(:unread_listing_message_threads_count, actual_count)
    end
  end
end
