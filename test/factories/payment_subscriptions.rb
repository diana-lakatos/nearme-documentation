FactoryGirl.define do
  factory :payment_subscription do
    association :payment_method, factory: :credit_card_payment_method
    association :credit_card
  end
end
