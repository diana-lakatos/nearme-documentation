class AddSubjectToWorkflowAlerts < ActiveRecord::Migration
  def change
    add_column :workflow_alerts, :subject, :text
  end
end
