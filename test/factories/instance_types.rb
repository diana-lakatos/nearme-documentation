FactoryGirl.define do

  factory :instance_type do
    sequence(:name) { |n| "Instance Type #{n}" }
  end
end
