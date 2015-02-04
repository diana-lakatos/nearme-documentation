# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rating_system do
    subject %w(host guest item).sample
    instance
  end
end
