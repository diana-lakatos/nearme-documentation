FactoryGirl.define do

  factory :charge do
    association :user
    association(:payment, factory: :paid_payment)
    created_at { Time.zone.now }
    success true
    amount 1000
    currency 'USD'
    payment_gateway_mode "test"
    response { ActiveMerchant::Billing::Response.new true, 'OK', { "id" => "123", "message" => "message" } }

    factory :live_charge do
      payment_gateway_mode "live"
    end

    factory :test_charge do
      amount 11000 # Amount should be the same as payment amount
      payment_gateway_mode "test"
    end
  end
end
