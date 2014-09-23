FactoryGirl.define do
  factory :transactable do

    location

    ignore do
      photos_count_to_be_created 1
    end

    photo_not_required true

    initialize_with do
      new(transactable_type: (TransactableType.first.presence || FactoryGirl.create(:transactable_type_listing)))
    end

    after(:build) do |listing, evaluator|
      {
        "listing_type" => "Desk",
        "quantity" => "1",
        "confirm_reservations" => true,
        "daily_price_cents" => "5000",
        "description" => "Aliquid eos ab quia officiis sequi.",
        "name" => "Listing #{Random.rand(1000)}"
      }.each do |key, value|
        listing.properties[key] ||= value if listing.properties[key].nil?
      end
      if listing.photos.empty?
        listing.photos = create_list(:photo, evaluator.photos_count_to_be_created,
                                     listing: nil,
                                     creator: listing.location.creator)
      end
    end

    factory :always_open_listing do
      after(:create) do |listing|
        listing.availability.each_day do |dow, rule|
          listing.availability_rules.create!(:day => dow, :open_hour => 9, :close_hour => 18)
        end
      end
    end

    factory :free_listing do
      after(:build) do |listing|
        listing.properties.delete("daily_price_cents")
        listing.properties["free"] = true
      end
    end

    factory :hundred_dollar_listing do
      after(:build) do |listing|
        listing.properties["daily_price_cents"] = 100_00
      end
    end

    factory :listing_with_10_dollars_per_hour do
      after(:build) do |listing|
        listing.properties["hourly_price_cents"] = "1000"
        listing.properties["hourly_reservations"] = true
      end
    end

    factory :listing_at_5_5 do
      association(:location, factory: :location, latitude: "5.0", longitude: "5.0")
    end

    factory :listing_in_auckland do
      after(:build) do |listing|
        listing.properties["name"] = "Listing in Auckland #{Random.rand(1000)}"
      end

      association(:location, factory: :location_in_auckland)
    end

    factory :listing_in_adelaide do
      after(:build) do |listing|
        listing.properties["name"] = "Listing in Adeilaide #{Random.rand(1000)}"
      end
      association(:location, factory: :location_in_adelaide)
    end

    factory :listing_in_cleveland do
      after(:build) do |listing|
        listing.properties["name"] = "Listing in Cleveland #{Random.rand(1000)}"
      end

      association(:location, factory: :location_in_cleveland)

      factory :fully_booked_listing_in_cleveland do
        after(:create) do |listing|
          user = FactoryGirl.create(:user)
          dates = (4.days.from_now.to_date..10.days.from_now.to_date).reject { |d| listing.availability_for(d) == 0 }.to_a
          listing.reserve!(user, dates, listing.quantity)
        end
      end
    end

    factory :listing_in_san_francisco do
      after(:build) do |listing|
        listing.properties["name"] = "Listing in San Francisco #{Random.rand(1000)}"
      end
      association(:location, factory: :location_in_san_francisco)
    end


    factory :listing_in_san_francisco_address_components do
      after(:build) do |listing|
        listing.properties["name"] = "Listing in San Francisco #{Random.rand(1000)}"
      end
      association(:location, factory: :location_san_francisco_address_components)
    end

    factory :listing_in_wellington do
      after(:build) do |listing|
        listing.properties["name"] = "Listing in Wellington #{Random.rand(1000)}"
      end

      association(:location, factory: :location_in_wellington)
    end

    factory :demo_listing do
      after(:build) do |listing|
        listing.properties["daily_price_cents"] =  5000 + (100 * rand(50)).to_i
      end

      after(:create) do |listing, evaluator|
        listing.photos = FactoryGirl.create_list(:demo_photo, 2, creator: listing.location.creator )
        listing.save!
      end
    end

    factory :listing_from_transactable_type_with_price_constraints do
      association(:transactable_type, factory: :transactable_type_listing_with_price_constraints)
      initialize_with do
        new(transactable_type: (FactoryGirl.create(:transactable_type_listing_with_price_constraints)))
      end
    end

  end
end
