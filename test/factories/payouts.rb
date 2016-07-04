FactoryGirl.define do
  factory :payout do
    success true
    amount_cents 100
    # association(:charge)
  end
end
