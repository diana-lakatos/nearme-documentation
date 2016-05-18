FactoryGirl.define do
  factory :product_type, class: Spree::ProductType do
    sequence(:name) { |n| "Type ##{n}" }
    enable_reviews true

    trait :with_custom_attribute do
      after(:create) { |product| create(:custom_attribute_input, name: 'Manufacturer', target: product) }
    end

    factory :wizard_product_type do
      after(:build) do |product_type|
        Spree::ProductType.transaction do
          product_type.form_components << FactoryGirl.build(:form_component_product, form_componentable: product_type)
        end
      end
    end
  end
end
