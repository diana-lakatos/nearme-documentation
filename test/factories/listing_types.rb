FactoryGirl.define do

  factory :listing_type do
    sequence(:name) { |n| "Listing Type #{n}" }
  end
end
