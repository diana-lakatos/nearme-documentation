# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mailer_unsubscription do
    user nil
    mailer "MyString"
  end
end
