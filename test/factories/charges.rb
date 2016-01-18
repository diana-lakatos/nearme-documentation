FactoryGirl.define do

  factory :charge do
    association :user
    association(:payment, factory: :payment_paid)
    created_at { Time.zone.now }
    success true
    amount 1000
    currency 'USD'
    payment_gateway_mode "test"

    factory :live_charge do
      payment_gateway_mode "live"
    end

    factory :test_charge do
      amount 11000 # Amount should be the same as payment amount
      payment_gateway_mode "test"
    end
  end
end
