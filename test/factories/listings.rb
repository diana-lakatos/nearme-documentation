FactoryGirl.define do
  factory :listing do
    sequence(:name) do |n|
      "Listing #{n}"
    end

    description "Aliquid eos ab quia officiis sequi."
    location
    confirm_reservations true
    after(:create) do |listing|
      listing.unit_prices << FactoryGirl.create(:unit_price, listing: listing)
    end

    factory :free_listing do
      after(:create) do |listing|
       listing.price_cents = 0
      end
    end

    factory :hundred_dollar_listing do
      after(:create) do |listing|
       listing.price_cents = 100_00
      end
    end

    factory :poa_listing do
      after(:create) do |listing|
       listing.price_cents = nil
      end
    end

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
      sequence(:name) do |n|
        "Listing in Auckland #{n}"
      end

      association(:location, factory: :location_in_auckland)
    end

    factory :listing_in_cleveland do
      sequence(:name) do |n|
        "Listing in Cleveland #{n}"
      end

      association(:location, factory: :location_in_cleveland)
    end

    factory :listing_in_san_francisco do
      sequence(:name) do |n|
        "Listing in San Francisco #{n}"
      end

      association(:location, factory: :location_in_san_francisco)
    end

    factory :listing_in_wellington do
      sequence(:name) do |n|
        "Listing in Wellington #{n}"
      end

      association(:location, factory: :location_in_wellington)
    end

  end
end
