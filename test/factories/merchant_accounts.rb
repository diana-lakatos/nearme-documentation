FactoryGirl.define do
  factory :merchant_account do
    association(:merchantable, factory: :company)
    payment_gateway { FactoryGirl.create(:stripe_payment_gateway) }
    state 'verified'
    data { {} }

    factory :paypal_merchant_account do
    payment_gateway { FactoryGirl.create(:paypal_payment_gateway) }
    data { {email: 'receiver@example.com'} }

    end
  end
end
