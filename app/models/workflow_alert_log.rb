class WorkflowAlertLog < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :workflow_alert
  belongs_to :workflow_alert_weekly_aggregated_log
  belongs_to :workflow_alert_monthly_aggregated_log
  belongs_to :instance

  counter_culture :workflow_alert_weekly_aggregated_log, column_name: proc { |log| "#{log.alert_type}_count" }
  counter_culture :workflow_alert_monthly_aggregated_log, column_name: proc { |log| "#{log.alert_type}_count" }
end
