FactoryGirl.define do
  factory :listing do
    sequence(:name) do |n|
      "Listing #{n}"
    end

    description "Aliquid eos ab quia officiis sequi."
    price_cents 5000
    creator
    location
    confirm_reservations true

    factory :listing_with_amenity do
      after(:create) do |listing|
        listing.amenities << FactoryGirl.create(:amenity)
      end
    end

    factory :listing_with_organization do
      after(:create) do |listing|
        listing.organizations << FactoryGirl.create(:organization)
      end
    end

    factory :listing_at_5_5 do
      association(:location, factory: :location, latitude: "5.0", longitude: "5.0")
    end

    factory :listing_in_auckland do
      name "Listing in Auckland"
      association(:location, factory: :location_in_auckland)
    end

    factory :listing_in_cleveland do
      name "Listing in Cleveland"
      association(:location, factory: :location_in_cleveland)
    end

    factory :listing_in_san_francisco do
      name "Listing in San Francisco"
      association(:location, factory: :location_in_san_francisco)
    end

    factory :listing_in_wellington do
      name "Listing in Wellington"
      association(:location, factory: :location_in_wellington)
    end

  end
end
