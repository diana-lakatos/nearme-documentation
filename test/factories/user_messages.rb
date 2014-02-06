# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_message do
    association :author, factory: :user
    association :thread_context, factory: :listing
    thread_owner { author }
    thread_recipient { author }
    body "Hey whats up"
    instance_id { (Instance.default_instance.presence || FactoryGirl.create(:instance)).id }
  end
end
