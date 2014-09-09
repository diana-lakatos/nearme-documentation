FactoryGirl.define do
  factory :transactable_type_attribute do
    sequence(:name) { |n| "Attribute #{n}" }
    attribute_type "integer"
    label 'My Label'
    hint 'this is my hint'

    factory :transactable_type_attribute_required do
      validation_rules { { presence: {} } }
    end

    factory :transactable_type_attribute_array do
      name "array"
      attribute_type "array"
    end

    factory :transactable_type_attribute_input do
      html_tag 'input'
      placeholder 'My Placeholder'
    end

    factory :transactable_type_attribute_select do
      html_tag 'select'
      prompt 'My Prompt'
      valid_values { ['Value One', 'Value Two'] }
    end
  end
end
