class FixWorkflowAlertLogsIndexes < ActiveRecord::Migration
  def self.up
    remove_index :workflow_alert_monthly_aggregated_logs, name: 'wamal_instance_id_year_month_index'
    remove_index :workflow_alert_weekly_aggregated_logs, name: 'wamal_instance_id_year_week_number_index'
    add_index :workflow_alert_monthly_aggregated_logs, [:instance_id, :year, :month], name: 'wamal_instance_id_year_month_index', unique: true, where: '(deleted_at IS NULL)'
    add_index :workflow_alert_weekly_aggregated_logs, [:instance_id, :year, :week_number], name: 'wamal_instance_id_year_week_number_index', unique: true, where: '(deleted_at IS NULL)'
  end

  def self.down
    remove_index :workflow_alert_monthly_aggregated_logs, name: 'wamal_instance_id_year_month_index'
    remove_index :workflow_alert_weekly_aggregated_logs, name: 'wamal_instance_id_year_week_number_index'
    add_index :workflow_alert_monthly_aggregated_logs, [:instance_id, :year, :month], name: 'wamal_instance_id_year_month_index', unique: true
    add_index :workflow_alert_weekly_aggregated_logs, [:instance_id, :year, :week_number], name: 'wamal_instance_id_year_week_number_index', unique: true
  end
end
