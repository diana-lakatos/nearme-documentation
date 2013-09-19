FactoryGirl.define do
  factory :domain do
    sequence(:name) {|n| "desksnear#{n}.me" }
    target_type "Instance"
  end
end
