# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reservation_charge do
    reservation
    subtotal_amount_cents 1000
    service_fee_amount_guest_cents 200
    paid_at { Time.zone.now }
  end
end
