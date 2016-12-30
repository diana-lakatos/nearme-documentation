FactoryGirl.define do
  factory :transactable_no_action, class: 'Transactable' do
    sequence(:name) { |n| "Listing #{n}" }
    description 'Aliquid eos ab quia officiis sequi.'
    ignore do
      photos_count 0
    end
    location
    possible_payout true

    photo_not_required true
    initialize_with do
      new(transactable_type: (TransactableType.first.presence || FactoryGirl.create(:transactable_type_listing)))
    end

    after(:build) do |listing, evaluator|
      listing.action_type = FactoryGirl.build(:transactable_action_type, transactable: listing, transactable_type_action_type: listing.transactable_type.action_types.first)
      {
        'listing_type' => 'Desk'
      }.each do |key, value|
        listing.properties[key] ||= value if listing.properties[key].nil? if listing.properties.respond_to?(key)
      end
      if listing.photos.empty? && evaluator.photos_count > 0
        listing.photos = create_list(:photo, evaluator.photos_count,
                                     owner: listing,
                                     creator: listing.location.creator)
      end
    end

    factory :transactable do
      after(:build) do |listing, _evaluator|
        listing.action_type = FactoryGirl.build(:time_based_booking, :with_prices, transactable: listing, transactable_type_action_type: listing.transactable_type.time_based_booking)
      end

      trait :with_time_based_booking do
        after(:build) do |listing|
          listing.action_types.destroy_all
          listing.action_type = FactoryGirl.build(:time_based_booking, :with_prices, transactable: listing, transactable_type_action_type: listing.transactable_type.time_based_booking)
        end
      end

      factory :listing_with_10_dollars_per_hour, traits: [:with_time_based_booking] do
        after(:create) do |listing|
          listing.action_type.hour_pricings.first.update(price_cents: 10_00)
        end

        factory :listing_with_10_dollars_per_hour_and_24h do
          after(:create) do |listing|
            listing.action_type.availability_template = AvailabilityTemplate.find_by(name: '24/7')
            listing.save!
          end
        end
      end

      factory :transactable_purchase do
        after(:build) do |listing|
          listing.action_types.destroy_all
          listing.transactable_type.purchase_action ||= FactoryGirl.create(:transactable_type_purchase_action, transactable_type: listing.transactable_type)
          listing.action_type = FactoryGirl.build(:purchase_action, transactable: listing, transactable_type_action_type: listing.transactable_type.purchase_action)
        end
      end


      trait :free_listing do
        after(:build) do |listing|
          listing.action_types.destroy_all
          listing.action_type = FactoryGirl.build(:time_based_booking, :free, transactable: listing, transactable_type_action_type: listing.transactable_type.action_types.first)
        end
      end

      factory :transactable_with_doc_requirements do
        after(:build) do |transactable|
          transactable.create_upload_obligation(level: UploadObligation::LEVELS[0])
          transactable.document_requirements << FactoryGirl.create(:document_requirement, item: transactable)
        end
      end

      factory :subscription_transactable do
        after(:build) do |listing|
          listing.action_types.destroy_all
          listing.transactable_type.subscription_booking ||= FactoryGirl.build(:transactable_type_subscription_action, transactable_type: listing.transactable_type)
          listing.action_type = FactoryGirl.build(:subscription_booking, transactable: listing, transactable_type_action_type: listing.transactable_type.subscription_booking)
        end
        quantity 10
      end

      factory :always_open_listing do
        after(:build) do |listing|
          listing.action_type.availability_template = AvailabilityTemplate.find_by(name: '24/7')
        end
      end

      trait :fixed_price do
        after(:build) do |listing|
          listing.action_types.destroy_all
          listing.action_type = FactoryGirl.build(:event_booking, transactable: listing)
          listing.transactable_type.event_booking ||= FactoryGirl.build(:transactable_type_event_action, transactable_type: listing.transactable_type)
        end
        quantity 10
      end

      trait :desksnearme do
        after(:build) do |listing|
          listing.transactable_type.custom_attributes << FactoryGirl.create(:custom_attribute, :listing_types) unless listing.transactable_type.custom_attributes.find_by(name: 'listing_type')
          listing.transactable_type.custom_validators << FactoryGirl.create(:custom_validator, field_name: 'name', max_length: 50)
          listing.transactable_type.custom_validators << FactoryGirl.create(:custom_validator, field_name: 'description', max_length: 250)
        end
      end

      factory :listings_in_locations, traits: [:with_time_based_booking] do
        after(:build) do |listing|
          listing.action_type.pricings << FactoryGirl.build(:transactable_pricing, transactable_type_pricing: nil, number_of_units: 7)
          listing.action_type.pricings << FactoryGirl.build(:transactable_pricing, transactable_type_pricing: nil, number_of_units: 30)
        end

        factory :listing_at_5_5 do
          association(:location, factory: :location, latitude: '5.0', longitude: '5.0')
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

        factory :listing_in_auckland_fixed, traits: [:fixed_price] do
          after(:build) do |listing|
            listing.name = "Listing in Auckland #{Random.rand(1000)}"
          end

          association(:location, factory: :location_in_auckland)
          currency 'NZD'
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
      end

      factory :demo_listing do
        after(:build) do |listing|
          listing.action_type.pricing_for('1_day').price_cents = 5000 + (100 * rand(50)).to_i
        end

        after(:create) do |listing, _evaluator|
          listing.photos = FactoryGirl.create_list(:demo_photo, 2, creator: listing.location.creator, owner: listing)
          listing.save!
        end
      end

      factory :listing_from_transactable_type_with_price_constraints do
        initialize_with do
          new(transactable_type: (FactoryGirl.create(:transactable_type_listing_with_price_constraints)))
        end
      end
    end

    factory :transactable_offer do
      creator { User.sellers.last || FactoryGirl.build(:lister)}
      location { Location.last || FactoryGirl.build(:location, company: creator.default_company ) }
      after(:build) do |listing|
        listing.action_types.destroy_all
        listing.transactable_type.offer_action ||= FactoryGirl.create(:transactable_type_offer_action, transactable_type: listing.transactable_type)
        listing.action_type = FactoryGirl.build(:offer_action, transactable: listing, transactable_type_action_type: listing.transactable_type.offer_action)
        listing.transactable_collaborators.build(approved_by_user_at: Time.current, approved_by_owner_at: Time.current, user: User.buyers.last)
      end

      trait :free do
        after(:build) do |listing|
          listing.action_types.destroy_all
          listing.action_type = FactoryGirl.build(:offer_action, :free, transactable: listing, transactable_type_action_type: listing.transactable_type.action_types.first)
        end
      end

      factory :free_transactable_offer, traits: [:free]
    end

    factory :transactable_project do
      after(:build) do |listing, _evaluator|
        listing.build_action_type
        listing.action_type.transactable_type_action_type = TransactableType::ActionType.where(transactable_type_id: listing.transactable_type_id).first
      end

      factory :project do
        name 'Project Manhattan'
        description 'The Manhattan Project was a research and development project that produced the first nuclear weapon'
        seek_collaborators true
        creator
        photo_not_required true

        trait :featured do
          featured true
        end

        initialize_with do
          new(transactable_type: FactoryGirl.create(:transactable_type_project))
        end

        after(:build) do |project|
          project.topics << FactoryGirl.create(:topic)
        end

        after(:build) do |project|
          project.links << FactoryGirl.create(:link)
        end
      end
    end
  end
end
