FactoryGirl.define do

  factory :transactable_type, class: 'TransactableType' do
    sequence(:name) { |n| "Transactable Type #{n}" }

    bookable_noun 'Desk'
    lessor 'host'
    lessee 'guest'
    type 'TransactableType'
    searchable true
    enable_reviews true
    show_path_format '/listings/:id'
    searcher_type 'geo'
    search_engine 'elasticsearch'
    enable_photo_required false

    ignore do
      generate_rating_systems false
    end

    after(:build) do |transactable_type|
      transactable_type.custom_attributes << FactoryGirl.build(:custom_attribute, :listing_types, target: transactable_type)
      transactable_type.action_types << FactoryGirl.build(:transactable_type_time_based_action, transactable_type: transactable_type)
    end

    after(:create) do |transactable_type, evaluator|
      if evaluator.generate_rating_systems
        transactable_type.create_rating_systems
        transactable_type.rating_systems.update_all(active: true)
      end
      Utils::FormComponentsCreator.new(transactable_type).create!
    end

    factory :transactable_type_listing do
      sequence(:name) do |n|
        "Listing #{n}"
      end

      after(:build) do |transactable_type|
        TransactableType.transaction do
          transactable_type.availability_templates << FactoryGirl.build(:availability_template, transactable_type: transactable_type)
        end
      end

      factory :transactable_type_listing_with_price_constraints do
        max_hourly_price_cents 100_00
        min_hourly_price_cents 11_00
      end
      factory :transactable_type_listing_no_action do
        after(:build) do |transactable_type|
          TransactableType.transaction do
            transactable_type.action_types = [FactoryGirl.build(:transactable_type_action_type, transactable_type: transactable_type)]
          end
        end
      end
    end

    factory :transactable_type_location do
      after(:build) do |transactable_type|
        transactable_type.availability_templates << FactoryGirl.build(:availability_template, transactable_type: transactable_type)
      end
    end

    factory :transactable_type_csv_template do
      after(:build) do |transactable_type|
        transactable_type.availability_templates << FactoryGirl.build(:availability_template, transactable_type: transactable_type)
        transactable_type.custom_attributes = [
          FactoryGirl.build(:custom_attribute_required, target: transactable_type, name: 'my_attribute', attribute_type: 'string')
        ]
      end
      after(:build) do |transactable_type|
        transactable_type.action_types.first.pricings << FactoryGirl.build(:transactable_type_pricing, number_of_units: 7)
        transactable_type.action_types.first.pricings << FactoryGirl.build(:transactable_type_pricing, number_of_units: 30)
      end
    end

    factory :transactable_type_current_data do
      custom_csv_fields { [{ 'location' => 'name' }, { 'location' => 'email' }, { 'location' => 'external_id' }, { 'location' => 'location_type' }, { 'location' => 'description' }, { 'location' => 'special_notes' }, { 'address' => 'address' }, { 'address' => 'city' }, { 'address' => 'street' }, { 'address' => 'suburb' }, { 'address' => 'state' }, { 'address' => 'postcode' }, { 'transactable' => 'for_1_hour_price_cents' }, { 'transactable' => 'for_1_day_price_cents' }, { 'transactable' => 'name' }, { 'transactable' => 'my_attribute' }, { 'transactable' => 'external_id' }, { 'transactable' => 'enabled' }, { 'photo' => 'image_original_url' }] }

      after(:build) do |transactable_type|
        transactable_type.availability_templates << FactoryGirl.build(:availability_template, transactable_type: transactable_type)
        transactable_type.custom_attributes = [
          FactoryGirl.build(:custom_attribute_required, target: transactable_type, name: 'my_attribute', label: 'My Attribute', attribute_type: 'string'),
          FactoryGirl.build(:custom_attribute, target: transactable_type, name: 'name', label: 'Name', attribute_type: 'string')
        ]
      end
    end

    factory :transactable_type_subscription do
      after(:build) do |transactable_type|
        transactable_type.action_types << FactoryGirl.build(:transactable_type_subscription_action, transactable_type: transactable_type)
      end
    end
  end

  factory :transactable_type_project, class: 'TransactableType' do
    sequence(:name) { |n| "Project #{n}" }

    after(:build) do |transactable_type|
      transactable_type.custom_attributes = [
        FactoryGirl.build(:custom_attribute, target: transactable_type, name: 'summary', label: 'Summary', attribute_type: 'string')
      ]
    end

    after(:create) do |transactable_type|
      transactable_type_action_type = TransactableType::NoActionBooking.new
      transactable_type_action_type.transactable_type_id = transactable_type.id
      transactable_type_action_type.enabled = true
      transactable_type_action_type.save!
    end
  end

  factory :group_type, class: 'GroupType' do
    factory :public_group_type do
      sequence(:name) { |_n| 'Public' }
    end

    factory :moderated_group_type do
      sequence(:name) { |_n| 'Moderated' }
    end

    factory :private_group_type do
      sequence(:name) { |_n| 'Private' }
    end
  end
end
