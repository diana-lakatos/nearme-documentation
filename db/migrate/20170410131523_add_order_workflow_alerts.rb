class AddOrderWorkflowAlerts < ActiveRecord::Migration
  def self.up
    Instance.find_each do |instance|
      instance.set_context!
      Utils::DefaultAlertsCreator::OrderCreator.new.notify_host_of_marked_as_completed!

      # We delete the workflow alerts, for UoT it will be created manually after deploy
      WorkflowStep.find_by(associated_class: 'WorkflowStep::OrderWorkflow::Completed').workflow_alerts.delete_all
    end
  end

  def self.down
  end
end
