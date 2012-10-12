# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :listing_unit_price do
    price_cents 5000
    period 1440
    association :listing, factory: :listing
  end
end
