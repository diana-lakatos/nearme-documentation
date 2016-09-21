class AddHoursToExpiryAlertToTtActionTypes < ActiveRecord::Migration
  def change
    add_column :transactable_type_action_types, :send_alert_hours_before_expiry, :boolean, default: false, null: false
    add_column :transactable_type_action_types, :send_alert_hours_before_expiry_hours, :integer, default: 0, null: false
  end
end
