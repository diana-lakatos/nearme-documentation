FactoryGirl.define do
  factory :transactable_type_pricing, class: TransactableType::Pricing do
    association :action, factory: :transactable_type_action_type, strategy: :build
    number_of_units 1
    unit 'day'
    min_price_cents 0
    max_price_cents 100_000
    allow_free_booking true

    factory :transactable_type_hour_pricing do
      unit 'hour'
    end

    factory :transactable_type_event_pricing do
      allow_book_it_out_discount true
      allow_exclusive_price true
      unit 'event'
    end

    factory :transactable_type_subscription_pricing do
      unit 'subscription_month'
    end

  end
end