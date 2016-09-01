class AddBccTypeToWorkflowAlerts < ActiveRecord::Migration
  def change
    add_column :workflow_alerts, :bcc_type, :string, default: nil
  end
end
