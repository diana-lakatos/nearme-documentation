FactoryGirl.define do
  factory :transactable_type, class: 'ServiceType' do

    sequence(:name) { |n| "Transactable Type #{n}" }

    action_daily_booking true
    action_weekly_booking true
    action_monthly_booking true
    action_free_booking true
    action_hourly_booking true
    availability_options { { "defer_availability_rules" => true,"confirm_reservations" => { "default_value" => true, "public" => true } } }
    action_recurring_booking false
    action_rfq false
    service_fee_guest_percent '10.00'
    service_fee_host_percent '10.00'
    bookable_noun 'Desk'
    lessor 'host'
    lessee 'guest'
    type 'ServiceType'
    searchable true
    enable_reviews true

    ignore do
      generate_rating_systems false
    end

    after(:build) do |transactable_type|
      transactable_type.custom_attributes << FactoryGirl.build(:custom_attribute, :listing_types)
    end

    after(:create) do |transactable_type, evaluator|
      if evaluator.generate_rating_systems
        transactable_type.create_rating_systems
        transactable_type.rating_systems.update_all(active: true)
      end
    end

    factory :transactable_type_listing do
      sequence(:name) do |n|
        "Listing #{n}"
      end
      type 'ServiceType'

      after(:build) do |transactable_type|
        TransactableType.transaction do
          transactable_type.availability_templates << FactoryGirl.build(:availability_template, transactable_type: transactable_type)
          transactable_type.form_components << FactoryGirl.build(:form_component_transactable, form_componentable: transactable_type)
          transactable_type.custom_attributes << FactoryGirl.build(:custom_attribute, :listing_types)
        end
      end

      factory :transactable_type_listing_with_price_constraints do
        max_hourly_price_cents 100_00
        min_hourly_price_cents 11_00
      end

    end

    factory :transactable_type_buy_sell do
      sequence(:name) do |n|
        "Buy/Sell #{n}"
      end
      buyable true
    end

    factory :transactable_type_location do
      after(:build) do |transactable_type|
        transactable_type.availability_templates << FactoryGirl.build(:availability_template, :transactable_type => transactable_type)
      end
    end

    factory :transactable_type_csv_template do
      after(:build) do |transactable_type|
        transactable_type.availability_templates << FactoryGirl.build(:availability_template, :transactable_type => transactable_type)
        transactable_type.custom_attributes = [
          FactoryGirl.build(:custom_attribute_required, target: transactable_type, name: 'my_attribute', attribute_type: 'string'),
        ]
      end
    end

    factory :transactable_type_current_data do

      action_free_booking false
      action_hourly_booking true
      action_daily_booking true
      action_weekly_booking true
      action_monthly_booking true

      availability_options { { "defer_availability_rules" => true,"confirm_reservations" => { "default_value" => true, "public" => false } } }
      custom_csv_fields { [{'location' => 'name'}, {'location' => 'email'}, {'location' => 'external_id'}, {'location' => 'location_type'}, {'location' => 'description'}, { 'location' => 'special_notes'}, { 'address' => 'address'}, {'address' => 'city'}, { 'address' => 'street' }, { 'address' => 'suburb' }, { 'address' => 'state' }, { 'address' => 'postcode' }, { 'transactable' => 'monthly_price_cents' }, { 'transactable' => 'weekly_price_cents' }, { 'transactable' => 'daily_price_cents' }, { 'transactable' => 'name' }, { 'transactable' => 'my_attribute' }, { 'transactable' => 'external_id' }, { 'transactable' => 'enabled' }, { 'photo' => 'image_original_url' }] }

      after(:build) do |transactable_type|
        transactable_type.availability_templates << FactoryGirl.build(:availability_template, :transactable_type => transactable_type)
        transactable_type.custom_attributes = [
          FactoryGirl.build(:custom_attribute_required, target: transactable_type, name: 'my_attribute', label: 'My Attribute', attribute_type: 'string'),
          FactoryGirl.build(:custom_attribute, target: transactable_type, name: 'name', label: 'Name', attribute_type: 'string')
        ]
      end
    end

    factory :transactable_type_subscription do
      action_daily_booking false
      action_weekly_booking false
      action_monthly_booking false
      action_free_booking false
      action_hourly_booking false
      action_monthly_subscription_booking true
    end
  end

  factory :project_type, class: 'ProjectType' do
    sequence(:name) { |n| "Project #{n}" }
  end
end
