class CreateWorkflowApiCallForIntel < ActiveRecord::Migration
  def up
    i = Instance.find_by(id: 132)
    return true unless i.present?
    i.set_context!
    alert = WorkflowStep.find_by(associated_class: 'WorkflowStep::SignUpWorkflow::AccountCreated').workflow_alerts.build
    alert.name = 'Update profile hook'
    alert.alert_type = 'api_call'
    alert.endpoint = 'https://idz-profile-rest-prod.wdg.infra-host.com/api/update-profile'
    alert.request_type = 'POST'
    alert.headers = {
      'Content-Type' => 'application/json',
      'x-token' => "{{ platform_context.webhook_token}}"
    }.to_json
    alert.payload_data = {
      'enterprise_id' => "{{ user.external_id }}"
    }.to_json
    alert.save!
  end

  def down
  end
end
