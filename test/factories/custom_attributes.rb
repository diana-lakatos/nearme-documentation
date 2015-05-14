FactoryGirl.define do
  factory :custom_attribute, class: 'CustomAttributes::CustomAttribute' do
    sequence(:name) { |n| "Attribute #{n}" }
    attribute_type "integer"
    label 'My Label'
    hint 'this is my hint'

    trait :listing_types do
      name 'listing_type'
      valid_values { ["Desk", "Meeting Room", "Office Space", "Salon Booth"] }
      attribute_type 'string'
      required 1
    end

    factory :custom_attribute_required do
      validation_rules { { presence: {} } }
    end

    factory :custom_attribute_array do
      name "array"
      attribute_type "array"
    end

    factory :custom_attribute_input do
      html_tag 'input'
      placeholder 'My Placeholder'
    end

    factory :custom_attribute_textarea do
      html_tag 'textarea'
      placeholder 'My Placeholder'
    end

    factory :custom_attribute_check_box do
      html_tag 'check_box'
    end

    factory :custom_attribute_switch do
      html_tag 'switch'
    end

    factory :custom_attribute_check_box_list do
      html_tag 'check_box_list'
      valid_values { ['Value One', 'Value Two'] }
    end

    factory :custom_attribute_radio_buttons do
      html_tag 'radio_buttons'
      valid_values { ['Value One', 'Value Two'] }
    end

    factory :custom_attribute_select do
      html_tag 'select'
      prompt 'My Prompt'
      valid_values { ['Value One', 'Value Two'] }
    end

  end
end
