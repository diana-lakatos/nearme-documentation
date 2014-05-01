FactoryGirl.define do
  factory :transactable_type do

    sequence(:name) { |n| "Transactable Type #{n}" }

    factory :transactable_type_listing do
      sequence(:name) do |n|
        "Listing #{n}"
      end
      pricing_options { { "free"=>"1", "hourly"=>"1", "daily"=>"1", "weekly"=>"1", "monthly"=>"1" } }

      after(:build) do |transactable_type|
        TransactableType.transaction do
          Utils::TransactableTypeAttributesCreator.new(transactable_type).create_listing_attributes!
        end
      end

      factory :transactable_type_listing_with_price_constraints do
        pricing_validation { { "hourly" => { "max" => "100", "min" => "11" } } }
      end

    end
  end
end
