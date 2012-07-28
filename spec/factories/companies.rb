FactoryGirl.define do
  factory :company do
    sequence(:name) { |n| name { "Company #{n}" } }
    creator
  end
end
