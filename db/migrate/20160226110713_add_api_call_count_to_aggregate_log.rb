class AddApiCallCountToAggregateLog < ActiveRecord::Migration
  def change
    add_column :workflow_alert_weekly_aggregated_logs, :api_call_count, :integer
    add_column :workflow_alert_monthly_aggregated_logs, :api_call_count, :integer
  end
end
