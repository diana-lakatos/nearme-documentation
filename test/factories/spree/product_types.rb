FactoryGirl.define do
  factory :product_type, class: Spree::ProductType do
    sequence(:name) { |n| "Type ##{n}" }
    enable_reviews true
    searcher_type 'fulltext'
    search_engine 'postgres'

    trait :with_custom_attribute do
      after(:create) { |product| create(:custom_attribute_input, name: 'Manufacturer', target: product) }
    end

    after(:create) do |product_type|
      Utils::FormComponentsCreator.new(product_type).create!
    end

  end
end

