FactoryGirl.define do
  factory :payment do

    paid_at { Time.zone.now }
    subtotal_amount_cents { 100_00 }
    service_fee_amount_guest_cents { 10_00 }
    association(:payable, :factory => :reservation_with_credit_card)

    factory :payment_unpaid do
      paid_at nil
    end

    factory :payment_paid do
      paid_at Time.now
      association(:payable, :factory => :confirmed_reservation)

      after(:create) do |payment|
        payment.company.schedule_payment_transfer
        payment.reload
      end
    end

    factory :order_charge do
      subtotal_amount_cents { 50_00 }
      service_fee_amount_guest_cents { 5_00 }
      association(:payable, :factory => :completed_order_with_totals)

      factory :payment_order_unpaid do
        paid_at nil
      end
    end
  end
end
