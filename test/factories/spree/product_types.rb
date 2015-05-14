FactoryGirl.define do
  factory :product_type, class: Spree::ProductType do
    name { 'Item' }

    trait :with_custom_attribute do
      after(:create) { |product| create(:custom_attribute_input, name: 'Manufacturer', target: product) }
    end

    factory :wizard_product_type do
      after(:build) do |product_type|
        Spree::ProductType.transaction do
          product_type.form_components << FactoryGirl.build(:product_form_component, form_componentable: product_type)
        end
      end
    end
  end
end
