FactoryGirl.define do
  factory :transactable_type_attribute do
    sequence(:name) { |n| "Attribute #{n}" }
    attribute_type "integer"
  end
end
