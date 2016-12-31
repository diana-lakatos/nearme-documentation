FactoryGirl.define do
  factory :transactable_action_type, class: Transactable::ActionType do
    association :transactable, factory: :transactable_no_action, strategy: :build
    association :transactable_type_action_type, strategy: :build
    enabled true
    type 'Transactable::NoActionBooking'
    minimum_booking_minutes 60

    factory :time_based_booking, class: Transactable::TimeBasedBooking do
      association :transactable, strategy: :build
      association :transactable_type_action_type, factory: :transactable_type_time_based_action, strategy: :build
      type 'Transactable::TimeBasedBooking'
      availability_template

      trait :free do
        after(:build) do |at|
          at.pricings << FactoryGirl.build(
            :transactable_pricing,
            :free,
            action: at,
            transactable_type_pricing: at.transactable_type_action_type.pricings.first
          )
        end
      end

      trait :with_prices do
        after(:build) do |at|
          at.pricings << FactoryGirl.build(
            :transactable_pricing,
            action: at,
            transactable_type_pricing: at.transactable_type_action_type.pricing_for('1_day')
          )
          at.pricings << FactoryGirl.build(
            :hour_pricing,
            action: at,
            transactable_type_pricing: at.transactable_type_action_type.pricing_for('1_hour')
          )
        end
      end
    end

    factory :purchase_action, class: Transactable::PurchaseAction do
      association :transactable, strategy: :build
      type 'Transactable::PurchaseAction'

      after(:build) do |at|
        at.transactable_type_action_type ||= FactoryGirl.build(:transactable_type_purchase_action, transactable_type: at.transactable.transactable_type)
        at.pricings << FactoryGirl.build(
          :purchase_pricing,
          action: at,
          transactable_type_pricing: at.transactable_type_action_type.pricing_for('1_item')
        )
      end
    end

    factory :offer_action, class: Transactable::OfferAction do
      association :transactable, strategy: :build
      type 'Transactable::OfferAction'

      after(:build) do |at|
        at.transactable_type_action_type ||= FactoryGirl.build(:transactable_type_offer_action, transactable_type: at.transactable.transactable_type)
        at.pricings << FactoryGirl.build(
          :offer_pricing,
          action: at,
          transactable_type_pricing: at.transactable_type_action_type.pricing_for('1_item')
        )
      end

      trait :free do
        after(:build) do |at|
          at.pricings = [FactoryGirl.build(
            :offer_pricing,
            :free,
            action: at,
            transactable_type_pricing: at.transactable_type_action_type.pricings.first
          )]
        end
      end
    end

    factory :event_booking, class: Transactable::EventBooking do
      association :transactable, strategy: :build
      type 'Transactable::EventBooking'

      after(:build) do |at|
        unless at.transactable_type_action_type && at.transactable_type_action_type.pricing_for('1_event')
          at.transactable_type_action_type = FactoryGirl.build(:transactable_type_event_action, transactable_type: at.transactable.transactable_type)
        end
        at.schedule = FactoryGirl.build(:schedule, scheduable: at)
        at.pricings << FactoryGirl.build(
          :event_pricing, :with_exclusive_price, :with_book_it_out,
          action: at,
          transactable_type_pricing: at.transactable_type_action_type.pricing_for('1_event')
        )
      end
    end

    factory :subscription_booking, class: Transactable::SubscriptionBooking do
      association :transactable, strategy: :build
      association :transactable_type_action_type, factory: :transactable_type_subscription_action, strategy: :build
      type 'Transactable::SubscriptionBooking'

      after(:build) do |at|
        at.pricings = [FactoryGirl.build(
          :subscription_pricing,
          action: at,
          transactable_type_pricing: at.transactable_type_action_type.pricing_for('1_subscription_month')
        )]
      end
    end
  end
end
