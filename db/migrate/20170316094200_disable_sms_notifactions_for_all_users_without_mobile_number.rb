# frozen_string_literal: true
class DisableSmsNotifactionsForAllUsersWithoutMobileNumber < ActiveRecord::Migration
  def up
    User.where(mobile_number: nil).update_all(sms_notifications_enabled: false)
    change_column_default(:users, :sms_notifications_enabled, false)
  end

  def down
    change_column_default(:users, :sms_notifications_enabled, true)
  end
end
