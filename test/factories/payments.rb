FactoryGirl.define do
  factory :payment do

    paid_at { Time.zone.now }
    subtotal_amount_cents { 100_00 }
    service_fee_amount_guest_cents { 10_00 }
    association(:reference, :factory => :reservation_with_credit_card)

    factory :reservation_charge do

      factory :reservation_charge_unpaid do
        paid_at nil
      end

    end

    factory :order_charge do
      subtotal_amount_cents { 50_00 }
      service_fee_amount_guest_cents { 5_00 }
      association(:reference, :factory => :completed_order_with_totals)

      factory :payment_order_unpaid do
        paid_at nil
      end

    end
  end
end
