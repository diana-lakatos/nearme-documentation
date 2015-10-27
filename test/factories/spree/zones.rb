FactoryGirl.define do
  factory :zone, class: Spree::Zone do
    name { generate(:random_string) }
    description { generate(:random_string) }
    country_ids { [Country.first.try(:id) || create(:country).id]}
  end
end
