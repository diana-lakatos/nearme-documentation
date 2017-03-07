FactoryGirl.define do
  factory :transactable_type_action_type, class: TransactableType::ActionType do
    type 'TransactableType::NoActionBooking'
    minimum_booking_minutes 60
    service_fee_guest_percent 10.0
    service_fee_host_percent 10.0
    enabled true

    factory :transactable_type_time_based_action, class: TransactableType::TimeBasedBooking do
      type 'TransactableType::TimeBasedBooking'

      after(:build) do |at|
        at.pricings << FactoryGirl.build(
          :transactable_type_pricing,
          action: at
        )
        at.pricings << FactoryGirl.build(
          :transactable_type_hour_pricing,
          action: at
        )
      end
    end


    factory :transactable_type_offer_action, class: TransactableType::OfferAction do
      type 'TransactableType::OfferAction'

      cancellation_policy_enabled '1'
      cancellation_policy_hours_for_cancellation 24
      cancellation_policy_penalty_hours 1.5
      service_fee_guest_percent 0
      service_fee_host_percent 30

      after(:build) do |at|
        at.pricings << FactoryGirl.build(
          :transactable_type_offer_pricing,
          action: at
        )
      end
    end

    factory :transactable_type_purchase_action, class: TransactableType::PurchaseAction do
      type 'TransactableType::PurchaseAction'

      after(:build) do |at|
        at.pricings << FactoryGirl.build(
          :transactable_type_purchase_pricing,
          action: at
        )
      end
    end

    factory :transactable_type_event_action, class: TransactableType::EventBooking do
      type 'TransactableType::EventBooking'

      after(:build) do |at|
        at.pricings << FactoryGirl.build(
          :transactable_type_event_pricing,
          action: at
        )
      end
    end

    factory :transactable_type_subscription_action, class: TransactableType::SubscriptionBooking do
      type 'TransactableType::SubscriptionBooking'

      after(:build) do |at|
        at.pricings = [FactoryGirl.build(
          :transactable_type_subscription_pricing,
          action: at
        )]
      end
    end

    factory :transactable_type_subscription_pro_rated_action, class: TransactableType::SubscriptionBooking do
      type 'TransactableType::SubscriptionBooking'

      after(:build) do |at|
        at.pricings = [FactoryGirl.build(
          :transactable_type_subscription_pro_rated_pricing,
          action: at
        )]
      end
    end
  end
end
