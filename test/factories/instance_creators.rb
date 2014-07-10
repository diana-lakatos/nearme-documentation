FactoryGirl.define do
  factory :instance_creator do
    sequence(:email) { |n| "instance-creator-#{n}@example.com" }
  end
end
