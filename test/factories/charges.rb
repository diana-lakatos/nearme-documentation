FactoryGirl.define do

  factory :charge do
    association :user
    association :reference, :factory => :reservation_with_credit_card
    created_at { Time.zone.now }
    success true
    amount 1000
    currency 'USD'
  end

end
