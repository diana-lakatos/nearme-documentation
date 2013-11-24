FactoryGirl.define do

  factory :listing_type do
    sequence(:name) { |n| "Listing Type #{n}" }
    instance { (Instance.default_instance || FactoryGirl.create(:instance)) }
  end
end
