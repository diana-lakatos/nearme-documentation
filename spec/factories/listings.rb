FactoryGirl.define do
  factory :listing do
    sequence(:name) do |n|
      "Listing #{n}"
    end

    price_cents 5000
    creator
    location

    factory :listing_with_amenity do
      after(:create) do |listing|
        listing.amenities << FactoryGirl.create(:amenity, id: 1)
      end
    end
    factory :listing_with_organization do
      after(:create) do |listing|
        listing.organizations << FactoryGirl.create(:organization, id: 1)
      end
    end
    factory :listing_at_5_5 do
      association(:location, factory: :location, latitude: "5.0", longitude: "5.0")
    end

    factory :listing_in_auckland do
      association(:location, factory: :location_in_auckland)
    end

    factory :listing_in_cleveland do
      association(:location, factory: :location_in_cleveland)
    end

    factory :listing_in_san_francisco do
      association(:location, factory: :location_in_san_francisco)
    end
  end
end
