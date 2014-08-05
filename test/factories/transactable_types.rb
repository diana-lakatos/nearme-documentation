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
          Utils::TransactableTypeAttributesCreator.new(transactable_type).create_listing_attributes!
        end
      end

      factory :transactable_type_listing_with_price_constraints do
        pricing_validation { { "hourly" => { "max" => "100", "min" => "11" } } }
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
        transactable_type.transactable_type_attributes = [FactoryGirl.build(:transactable_type_attribute_required, transactable_type: transactable_type, name: 'my_attribute', attribute_type: 'string')]
      end
    end
  end
end
