FactoryGirl.define do
  factory :base_product, class: Spree::Product do
    sequence(:name) { |n| "Product ##{n} - #{Kernel.rand(9999)}" }
    description { Faker::Lorem.paragraph(5) }
    price 19.99
    cost_price 17.00
    sequence(:sku) { |n| "ABC#{n}"}
    available_on { 1.year.ago }
    deleted_at nil
    shipping_category { |r| Spree::ShippingCategory.first || r.association(:shipping_category) }
    administrator { |p| p.association(:user) }
    company { |p| p.association(:company) }
    product_type { Spree::ProductType.first || FactoryGirl.create(:product_type)}

    # ensure stock item will be created for this products master
    before(:create) { create(:stock_location) if Spree::StockLocation.count == 0 }

    after(:create) do |p|
      create_list(:variant, 1, product: p, is_master: true)
      p.reload
      p.variants_including_master.each { |v| v.save! }
    end

    after(:create) do |p|
      p.stock_items.each { |stock_item| stock_item.adjust_count_on_hand(10) }
    end

    factory :custom_product do
      name 'Custom Product'
      price 17.99

      tax_category { |r| Spree::TaxCategory.first || r.association(:tax_category) }
    end

    factory :product do
      tax_category { |r| Spree::TaxCategory.first || r.association(:tax_category) }

      factory :product_with_option_types do
        after(:create) { |product| create(:product_option_type, product: product) }
      end
    end
  end
end
