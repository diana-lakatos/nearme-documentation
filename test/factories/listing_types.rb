FactoryGirl.define do

  factory :listing_type do
    sequence(:name) { |n| "Listing Type #{n}" }
    instance_id { (Instance.default_instance.presence || FactoryGirl.create(:instance)).id }
  end
end
