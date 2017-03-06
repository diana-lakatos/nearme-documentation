FactoryGirl.define do
  factory :transactable_pricing, class: Transactable::Pricing do
    initialize_with do
      new(transactable_type_pricing: FactoryGirl.build(:transactable_type_pricing))
    end
    association :action, factory: :time_based_booking, strategy: :build
    number_of_units 1
    unit 'day'
    price_cents 5000
    is_free_booking false
    enabled '1'

    trait :free do
      price_cents 0
      is_free_booking true
    end

    factory :hour_pricing do
      unit 'hour'
    end

    factory :purchase_pricing do
      unit 'item'
    end

    factory :offer_pricing do
      unit 'item'
    end

    factory :event_pricing do
      unit 'event'
      trait :with_book_it_out do
        has_book_it_out_discount '1'
        book_it_out_discount 20
        book_it_out_minimum_qty 8
      end
      trait :with_exclusive_price do
        has_exclusive_price '1'
        exclusive_price_cents 89_900
      end
    end

    factory :subscription_pricing do
      unit 'subscription_month'
      price_cents 1670
    end

    factory :subscription_pro_rated_pricing do
      unit 'subscription_month_pro_rated'
      price_cents 1670
    end
  end
end
