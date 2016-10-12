FactoryGirl.define do
  factory :billing_authorization do
    sequence(:token) { |n| "token#{n}" }
    success true
    association(:reference, factory: :unconfirmed_reservation)

    factory :failed_billing_authorization do
      success false
    end
  end
end
