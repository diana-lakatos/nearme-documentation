class CapitalizeAdministratorInWorkflowAlerts < ActiveRecord::Migration
  def change
    connection.execute <<-SQL
      UPDATE workflow_alerts
      SET
        recipient_type = 'Administrator'
      WHERE recipient_type LIKE 'administrator';
    SQL
  end
end
