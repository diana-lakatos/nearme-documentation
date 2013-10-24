FactoryGirl.define do
  factory :listing_message do
    listing
    association :author, factory: :user
    owner { author }
    body "Hey whats up"
  end
end
