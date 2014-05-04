FactoryGirl.define do
  factory :transactable_type do

    sequence(:name) { |n| "Transactable Type #{n}" }

    factory :transactable_type_listing do
      sequence(:name) do |n|
        "Listing #{n}"
      end

      after(:build) do |transactable_type|
        TransactableType.transaction do
          Utils::TransactableTypeAttributesCreator.new(transactable_type).create_listing_attributes!
        end
      end
    end
  end
end
