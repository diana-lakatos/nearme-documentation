FactoryGirl.define do
  factory :company do
    sequence(:name) { |n| "Company #{n}" }
    creator
    url "http://google.com"
  end
end
