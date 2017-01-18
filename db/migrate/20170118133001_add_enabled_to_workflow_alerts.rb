class AddEnabledToWorkflowAlerts < ActiveRecord::Migration
  def change
    add_column :workflow_alerts, :enabled, :boolean, default: true
  end
end
