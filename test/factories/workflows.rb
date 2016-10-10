FactoryGirl.define do
  factory :workflow do
    sequence(:name) { |n| "Workflow #{n}" }
    workflow_type 'dummy_type'
  end
end
