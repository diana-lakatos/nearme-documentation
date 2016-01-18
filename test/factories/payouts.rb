FactoryGirl.define do
  factory :payout do
    success true
    amount 100
    # association(:charge)
  end
end
