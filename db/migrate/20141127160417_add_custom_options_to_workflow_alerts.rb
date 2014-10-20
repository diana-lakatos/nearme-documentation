class AddCustomOptionsToWorkflowAlerts < ActiveRecord::Migration
  def change
    add_column :workflow_alerts, :custom_options, :text
  end
end
