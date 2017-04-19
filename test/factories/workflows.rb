# frozen_string_literal: true
FactoryGirl.define do
  factory :workflow do
    sequence(:name) { |n| "Workflow #{n}" }
    workflow_type 'dummy_type'

    factory :customization_workflow do
      workflow_type 'customization_workflow'
    end
  end
end
