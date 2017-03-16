# frozen_string_literal: true
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_message do
    association :author, factory: :user_with_sms_notifications_enabled
    association :thread_context, factory: :transactable
    thread_owner { author }
    thread_recipient { author }
    body 'Hey whats up'
  end
end
