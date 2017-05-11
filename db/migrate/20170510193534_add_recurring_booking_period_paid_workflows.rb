class AddRecurringBookingPeriodPaidWorkflows < ActiveRecord::Migration
  def self.up
    Instance.find_each do |i|
      i.set_context!

      Utils::DefaultAlertsCreator::RecurringBookingPeriodCreator.new.create_all!

      if i.id != Instances::InstanceFinder::INSTANCE_IDS[:spacerau] &&
        i.id != Instances::InstanceFinder::INSTANCE_IDS[:spacercom]

        # Above we also created Workflow Steps; now we delete the workflow alerts for non-spacer instances
        # as we don't want to impact the way the MPs currently work
        WorkflowStep.find_by(associated_class: 'WorkflowStep::RecurringBookingPeriodWorkflow::Paid').workflow_alerts.delete_all
      end
    end
  end

  def self.down
    Instance.find_each do |i|
      i.set_context!

      WorkflowStep.find_by(associated_class: 'WorkflowStep::RecurringBookingPeriodWorkflow::Paid').destroy
    end
  end
end
