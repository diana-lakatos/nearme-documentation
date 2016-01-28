FactoryGirl.define do
  factory :recurring_booking do
    association :owner, factory: :user
    association :listing, factory: :subscription_transactable
    association :credit_card
    association :payment_gateway, factory: :stripe_payment_gateway
    start_on { Time.zone.now.next_week }
    platform_context_detail_type "Instance"
    platform_context_detail_id { PlatformContext.current.instance.id }
    quantity 1
    state 'unconfirmed'
    interval 'monthly'
    subtotal_amount_cents 1670
    currency 'USD'
    next_charge_date { Date.current }

    factory :confirmed_recurring_booking do

      after(:create) do |recurring_booking|
        recurring_booking.confirm!
      end
    end
  end

end

