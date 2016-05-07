FactoryGirl.define do
  factory :transactable do
    sequence(:name) { |n| "Listing #{n}" }
    description "Aliquid eos ab quia officiis sequi."
    ignore do
      photos_count 0
    end
    location
    daily_price_cents 5000
    action_daily_booking true
    possible_payout true

    photo_not_required true
    initialize_with do
      new(transactable_type: (ServiceType.first.presence || FactoryGirl.create(:transactable_type_listing)))
    end

    after(:build) do |listing, evaluator|
      {
        "listing_type" => "Desk"
      }.each do |key, value|
        listing.properties[key] ||= value if listing.properties[key].nil? if listing.properties.respond_to?(key)
      end
      if listing.photos.empty? && evaluator.photos_count > 0
        listing.photos = create_list(:photo, evaluator.photos_count,
                                     owner: listing,
                                     creator: listing.location.creator)
      end
    end

    factory :transactable_with_doc_requirements do
      after(:build) do |transactable|
        transactable.create_upload_obligation({level: UploadObligation::LEVELS[0]})
        transactable.document_requirements << FactoryGirl.create(:document_requirement, item: transactable)
      end
    end


    factory :subscription_transactable do
      action_subscription_booking true
      action_daily_booking false
      monthly_subscription_price_cents 1670
      booking_type 'subscription'
    end

    factory :always_open_listing do
      after(:create) do |listing|
        listing.availability_template = AvailabilityTemplate.find_by(name: '24/7')
        listing.save!
      end
    end

    trait :fixed_price do
      daily_price_cents nil
      action_daily_booking false
      fixed_price_cents 10000
      booking_type 'schedule'
      quantity 10
      after(:create) do |listing|
        listing.schedule = FactoryGirl.create(:simple_schedule, scheduable: listing)
        listing.save!
      end
    end

    trait :with_book_it_out do
      enable_book_it_out_discount '1'
      book_it_out_discount 20
      book_it_out_minimum_qty 8
    end

    trait :with_exclusive_price do
      enable_exclusive_price '1'
      exclusive_price_cents 89900
    end

    trait :desksnearme do
      after(:build) do |listing|
        listing.service_type.custom_attributes << FactoryGirl.create(:custom_attribute, :listing_types) unless listing.service_type.custom_attributes.find_by(name: 'listing_type')
        listing.transactable_type.custom_validators << FactoryGirl.create(:custom_validator, field_name: 'name', max_length: 50)
        listing.transactable_type.custom_validators << FactoryGirl.create(:custom_validator, field_name: 'description', max_length: 250)
      end
    end

    factory :free_listing do
      after(:build) do |listing|
        listing.daily_price_cents = nil
        listing.action_free_booking = true
      end
    end

    factory :hundred_dollar_listing do
      after(:build) do |listing|
        listing.daily_price_cents = 100_00
      end
    end

    factory :listing_with_10_dollars_per_hour do
      after(:build) do |listing|
        listing.hourly_price_cents = 10_00
        listing.action_hourly_booking = true
      end

      factory :listing_with_10_dollars_per_hour_and_24h do
        after(:build) do |listing|
          listing.daily_price_cents = nil
          listing.action_hourly_booking = true
          listing.action_daily_booking = false
        end

        after(:create) do |listing|
          listing.availability_template = AvailabilityTemplate.find_by(name: '24/7')
          listing.save!
        end
      end
    end

    factory :listing_at_5_5 do
      association(:location, factory: :location, latitude: "5.0", longitude: "5.0")
    end

    factory :listing_in_auckland do
      after(:build) do |listing|
        listing.name = "Listing in Auckland #{Random.rand(1000)}"
      end

      association(:location, factory: :location_in_auckland)
      currency 'NZD'
    end

    factory :listing_in_adelaide do
      after(:build) do |listing|
        listing.name = "Listing in Adeilaide #{Random.rand(1000)}"
      end
      association(:location, factory: :location_in_adelaide)
    end

    factory :listing_in_cleveland do
      after(:build) do |listing|
        listing.name = "Listing in Cleveland #{Random.rand(1000)}"
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
        listing.name = "Listing in San Francisco #{Random.rand(1000)}"
      end
      association(:location, factory: :location_in_san_francisco)
    end


    factory :listing_in_san_francisco_address_components do
      after(:build) do |listing|
        listing.name = "Listing in San Francisco #{Random.rand(1000)}"
      end
      association(:location, factory: :location_san_francisco_address_components)
    end

    factory :listing_in_wellington do
      after(:build) do |listing|
        listing.name = "Listing in Wellington #{Random.rand(1000)}"
      end

      association(:location, factory: :location_in_wellington)
    end

    factory :demo_listing do
      after(:build) do |listing|
        listing.daily_price_cents =  5000 + (100 * rand(50)).to_i
      end

      after(:create) do |listing, evaluator|
        listing.photos = FactoryGirl.create_list(:demo_photo, 2, creator: listing.location.creator, owner: listing )
        listing.save!
      end
    end

    factory :listing_from_transactable_type_with_price_constraints do
      initialize_with do
        new(transactable_type: (FactoryGirl.create(:transactable_type_listing_with_price_constraints)))
      end
    end

  end
end
