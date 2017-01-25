FactoryGirl.define do
  factory :recurring_booking do
    association :user
    owner { user }
    association :transactable, factory: :subscription_transactable
    company { transactable.try(:company) || Factory.build(:company) }
    creator { transactable.creator }

    payment_subscription { FactoryGirl.build(:payment_subscription, company: company) }
    start_on { Time.zone.now.next_week }
    quantity 1
    state 'inactive'
    currency 'USD'
    next_charge_date { Date.current }

    after(:build) do |booking|
      booking.transactable_pricing = booking.transactable.action_type.pricings.first
      booking.transactable_line_items << LineItem::Transactable.new(unit_price_cents: 1670, quantity: 1, name: booking.transactable.name)
    end

    trait :activated do
      after(:build) do |booking|
        booking.try_to_activate!
      end
    end

    factory :activated_recurring_booking, traits: [:activated]

    factory :confirmed_recurring_booking do
      state 'confirmed'
    end
  end
end
