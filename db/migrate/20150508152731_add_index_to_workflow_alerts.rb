class AddIndexToWorkflowAlerts < ActiveRecord::Migration
  def change
    add_index :workflow_alerts, [:instance_id, :workflow_step_id]
  end
end
