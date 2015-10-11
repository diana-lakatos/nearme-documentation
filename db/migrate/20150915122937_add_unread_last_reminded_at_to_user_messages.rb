class AddUnreadLastRemindedAtToUserMessages < ActiveRecord::Migration
  def change
    add_column :user_messages, :unread_last_reminded_at, :datetime, null: true
  end
end
