FactoryGirl.define do
  factory :payment_subscription do
    association :payment_method, factory: :credit_card_payment_method
    association :payment_source, factory: :credit_card
    association :payer, factory: :user
  end
end
