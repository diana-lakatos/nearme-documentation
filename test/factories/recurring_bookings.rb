FactoryGirl.define do
  factory :recurring_booking do
    association :owner, factory: :user
    association :listing, factory: :subscription_transactable
    association :payment_subscription
    start_on { Time.zone.now.next_week }
    platform_context_detail_type "Instance"
    platform_context_detail_id { PlatformContext.current.instance.id }
    quantity 1
    state 'unconfirmed'
    interval 'monthly'
    subtotal_amount_cents 1670
    currency 'USD'
    next_charge_date { Date.current }

    after(:build) do |booking|
      booking.transactable_pricing = booking.listing.action_type.pricings.first
    end

    factory :confirmed_recurring_booking do
      state 'confirmed'
    end
  end

end

