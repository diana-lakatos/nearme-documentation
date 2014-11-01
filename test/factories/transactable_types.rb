FactoryGirl.define do
  factory :transactable_type do

    sequence(:name) { |n| "Transactable Type #{n}" }
    pricing_options { { "free"=>"1", "hourly"=>"1", "daily"=>"1", "weekly"=>"1", "monthly"=>"1" } }
    availability_options { { "defer_availability_rules" => true,"confirm_reservations" => { "default_value" => true, "public" => true } } }

    factory :transactable_type_listing do
      sequence(:name) do |n|
        "Listing #{n}"
      end

      after(:build) do |transactable_type|
        TransactableType.transaction do
          transactable_type.availability_templates << FactoryGirl.build(:availability_template, :transactable_type => transactable_type)
          CustomAttributes::CustomAttribute::Creator.new(transactable_type).create_listing_attributes!
        end
      end

      factory :transactable_type_listing_with_price_constraints do
        pricing_validation { { "hourly" => { "max" => "100", "min" => "11" } } }
      end

    end

    factory :transactable_type_buy_sell do
      sequence(:name) do |n|
        "Buy/Sell"
      end
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
          FactoryGirl.build(:custom_attribute, target: transactable_type, name: 'name', label: 'my name label', attribute_type: 'string')
        ]
      end
    end

    factory :transactable_type_current_data do
      pricing_options { { "daily"=>"1", "weekly"=>"1", "monthly"=>"1" } }
      availability_options { { "defer_availability_rules" => true,"confirm_reservations" => { "default_value" => true, "public" => false } } }
      after(:build) do |transactable_type|
        transactable_type.availability_templates << FactoryGirl.build(:availability_template, :transactable_type => transactable_type)
        transactable_type.custom_attributes = [
          FactoryGirl.build(:custom_attribute_required, target: transactable_type, name: 'my_attribute', label: 'My Attribute', attribute_type: 'string'),
          FactoryGirl.build(:custom_attribute, target: transactable_type, name: 'name', label: 'Name', attribute_type: 'string')
        ]
      end
    end
  end
end
