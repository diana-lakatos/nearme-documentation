FactoryGirl.define do
  factory :shipping_method, class: Spree::ShippingMethod do
    sequence(:name) { |n| "ShippingCategory ##{n}" }
    zones { |a| [create(:zone)] }
    association(:calculator, factory: :calculator, strategy: :build)

    before(:create) do |shipping_method, evaluator|
      if shipping_method.shipping_categories.empty?
        shipping_method.shipping_categories << (Spree::ShippingCategory.first || create(:shipping_category))
      end
    end
  end
end
