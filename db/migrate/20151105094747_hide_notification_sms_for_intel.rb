class HideNotificationSmsForIntel < ActiveRecord::Migration
  def up
    Instance.where(is_community: true).where("name ilike '%intel%'").find_each do |instance|
      instance.hidden_ui_controls["dashboard/notification_preferences/sms"] = "1"
      instance.save!
    end
  end

  def down
    Instance.where(is_community: true).where("name ilike '%intel%'").find_each do |instance|
      instance.hidden_ui_controls.delete("dashboard/notification_preferences/sms")
      instance.save!
    end
  end
end
