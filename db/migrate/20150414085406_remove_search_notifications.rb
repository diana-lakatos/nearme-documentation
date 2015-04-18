class RemoveSearchNotifications < ActiveRecord::Migration
  def change
    drop_table :search_notifications
  end
end
