class AddForcedToEmailNotifications < ActiveRecord::Migration
  def change
    add_column :email_notifications, :forced, :boolean, dafault: false
  end
end
