class AddDelayToWorkflowAlerts < ActiveRecord::Migration
  def change
    add_column :workflow_alerts, :delay, :integer, default: 0
  end
end
