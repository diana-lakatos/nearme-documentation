# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :company_industry do
    company
    industry
  end
end
