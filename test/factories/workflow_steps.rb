FactoryGirl.define do
  factory :workflow_step do
    workflow
    sequence(:name) {|n| "Workflow Step #{n}"}
    associated_class 'dummy_event'

  end

end

