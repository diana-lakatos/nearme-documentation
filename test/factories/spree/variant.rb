FactoryGirl.define do
  factory :spree_variant, class: Spree::Variant do
    sequence(:sku) {|n| "sku#{n}" }
    weight_user 100
    width_user 101
    height_user 102
    depth_user 103
    price 100
  end
end
