FactoryGirl.define do
  factory :platform_email do
    sequence(:email) {|n| "platform_email_#{n}@example.com" }
  end
end
