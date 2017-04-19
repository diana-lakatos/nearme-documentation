# frozen_string_literal: true
FactoryGirl.define do
  factory :workflow_step do
    workflow
    sequence(:name) { |n| "Workflow Step #{n}" }
    associated_class 'DummyEvent'

    factory :customization_created_workflow do
      association :workflow, factory: :customization_workflow
      associated_class 'WorkflowStep::CustomizationWorkflow::Created'
      after(:build) do |workflow_step|
        workflow_step.workflow_alerts << FactoryGirl.build(:workflow_alert_enquirer)
      end
    end
  end
end
