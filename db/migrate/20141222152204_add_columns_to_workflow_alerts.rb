class AddColumnsToWorkflowAlerts < ActiveRecord::Migration
  def change
    add_column :workflow_alerts, :recipient, :string
    add_column :workflow_alerts, :from_type, :string
    add_column :workflow_alerts, :reply_to_type, :string
  end
end
