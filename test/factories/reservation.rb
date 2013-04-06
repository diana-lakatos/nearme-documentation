FactoryGirl.define do
  factory :reservation do
    association :user
    association :listing
    date { Date.today }
    payment_status 'pending'
    quantity 1

    factory :reservation_with_credit_card do
      payment_method 'credit_card'
    end
  end
end
