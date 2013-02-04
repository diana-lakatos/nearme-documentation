# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :industry do
    sequence(:name) do |n|
      "Industry #{n}"
    end

  end
end
