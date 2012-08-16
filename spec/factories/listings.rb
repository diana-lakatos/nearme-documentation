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

  end
end
#  factory :listing do
#    name { "Somewhere Else" }
#    address { "#{(rand * 99 + 1).to_i} York St Launceston TAS 7250" }
#    latitude { -34.705022 + (rand * 0.02 - 0.01) }
#    longitude { 138.710672 + (rand * 0.02 - 0.01) }
#    description { Faker::Lorem.paragraphs(2).join }
#    company_description { Faker::Lorem.paragraph }
#    confirm_reservations true
#    maximum_desks 3
#    association :creator, :factory => :user
#  end
