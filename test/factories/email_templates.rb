# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_template do
    association :instance
    type "test_type"
    subject "MyString"
    from "text@example.com"
    body "MyText"
  end
end
