class AddLayoutNameToWorkflowAlerts < ActiveRecord::Migration
  def change
    add_column :workflow_alerts, :layout_path, :string
  end
end
