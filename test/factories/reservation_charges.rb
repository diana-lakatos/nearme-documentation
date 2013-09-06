FactoryGirl.define do
  factory :reservation_charge do
    association :reservation
    paid_at { Time.zone.now }
    subtotal_amount_cents { 100_00 }
    service_fee_amount_cents { 10_00 }
  end
end

