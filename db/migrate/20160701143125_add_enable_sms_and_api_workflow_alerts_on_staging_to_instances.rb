class AddEnableSmsAndApiWorkflowAlertsOnStagingToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :enable_sms_and_api_workflow_alerts_on_staging, :boolean, null: false, default: false
  end
end
