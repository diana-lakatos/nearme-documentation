FactoryGirl.define do
  factory :shipping_method, class: Spree::ShippingMethod do
    transient do
      shipping_category_param nil
    end

    sequence(:name) { |n| "ShippingCategory ##{n}" }
    zones { |a| [create(:zone)] }
    association(:calculator, factory: :calculator, strategy: :build)

    before(:create) do |shipping_method, evaluator|
      if shipping_method.shipping_categories.empty?
        shipping_method.shipping_categories << (evaluator.shipping_category_param || Spree::ShippingCategory.first || create(:shipping_category))
      end
    end
  end
end
