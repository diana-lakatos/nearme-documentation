FactoryGirl.define do
  factory :payout do
    success true
    amount_cents 100
    # association(:charge)
  end

  factory :pending_payout, class: Payout do
    pending true
    amount_cents 100
    success false
  end
end
