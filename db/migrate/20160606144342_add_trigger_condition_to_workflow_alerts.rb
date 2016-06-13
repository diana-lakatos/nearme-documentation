class AddTriggerConditionToWorkflowAlerts < ActiveRecord::Migration
  def change
    add_column :workflow_alerts, :prevent_trigger_condition, :text, null: false, default: ''
  end
end
