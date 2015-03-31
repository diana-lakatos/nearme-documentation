FactoryGirl.define do
  factory :product_type, class: Spree::ProductType do
    name { 'Item' }

    trait :with_custom_attribute do
      after(:create) { |product| create(:custom_attribute_input, name: 'Manufacturer', target: product) }
    end
  end

end
