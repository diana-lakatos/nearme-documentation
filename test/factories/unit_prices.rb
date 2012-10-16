FactoryGirl.define do
  factory :unit_price do
    price_cents 5000
    period 1440
    association :listing, factory: :listing
  end
end
