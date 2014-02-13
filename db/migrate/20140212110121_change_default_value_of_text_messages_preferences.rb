class ChangeDefaultValueOfTextMessagesPreferences < ActiveRecord::Migration
  def up
    change_column :users, :sms_preferences, :string, default: Hash[%w(user_message reservation_state_changed new_reservation).map{|sp| [sp, true]}].to_yaml
  end

  def down
    change_column :users, :sms_preferences, :string, default: Hash[%w(user_message reservation_state_changed new_reservation).map{|sp| [sp, '1']}].to_yaml
  end
end
