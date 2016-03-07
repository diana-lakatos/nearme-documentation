class AddFieldsForApiCallWorkflowAlert < ActiveRecord::Migration
  def change
    add_column :workflow_alerts, :endpoint, :text
    add_column :workflow_alerts, :request_type, :string
    add_column :workflow_alerts, :use_ssl, :boolean
    add_column :workflow_alerts, :payload_data, :text, default: '{}'
    add_column :workflow_alerts, :headers, :text, default: '{}'
  end
end
