class AddTextMessagesPreferencesToUser < ActiveRecord::Migration

  def change
    add_column :users, :sms_notifications_enabled, :boolean, default: true
    add_column :users, :sms_preferences, :string, default: Hash[%w(user_message reservation_state_changed new_reservation).map{|sp| [sp, '1']}].to_yaml
  end
end
