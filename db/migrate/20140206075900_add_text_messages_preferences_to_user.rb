class AddTextMessagesPreferencesToUser < ActiveRecord::Migration

  class User < ActiveRecord::Base
  end

  def change
    add_column :users, :sms_notifications_enabled, :boolean, default: true
    add_column :users, :sms_preferences, :string

    all_sms_preferences = Hash[::User::SMS_PREFERENCES.map{|sp| [sp, '1']}].to_yaml
    User.all.each do |user|
      user.update_column(:sms_notifications_enabled, true)
      user.update_column(:sms_preferences, all_sms_preferences)
    end
  end
end
