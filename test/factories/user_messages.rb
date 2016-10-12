# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_message do
    association :author, factory: :user
    association :thread_context, factory: :transactable
    thread_owner { author }
    thread_recipient { author }
    body 'Hey whats up'
  end
end
