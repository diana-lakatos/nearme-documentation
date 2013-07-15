FactoryGirl.define do

  factory :charge do
    association :user
    association :reference, :factory => :reservation_with_credit_card
    created_at { Date.today }
    success true
    amount 1000
    currency 'USD'
  end

end
