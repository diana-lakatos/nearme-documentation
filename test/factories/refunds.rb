FactoryGirl.define do
  factory :refund do
    association(:payment)
    created_at { Time.zone.now }
    success true
    amount_cents 1000
    currency 'USD'
    receiver 'guest'
  end
end
