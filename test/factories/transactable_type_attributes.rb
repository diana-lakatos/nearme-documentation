FactoryGirl.define do
  factory :transactable_type_attribute do
    sequence(:name) { |n| "Attribute #{n}" }
    attribute_type "integer"

    factory :transactable_type_attribute_required do
      validation_rules { { presence: {} } }
    end

    factory :transactable_type_attribute_array do
      name "array"
      attribute_type "array"
    end
  end
end
