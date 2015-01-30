FactoryGirl.define do
  factory :zone, class: Spree::Zone do
    name { generate(:random_string) }
    description { generate(:random_string) }
    country_ids { [create(:country).id]}
  end
end
