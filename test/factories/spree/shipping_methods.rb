FactoryGirl.define do
  factory :shipping_category, class: Spree::ShippingCategory do
    sequence(:name) { |n| "ShippingCategory ##{n}" }

    after(:create) do |sc|

    end
  end
end
