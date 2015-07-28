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

    factory :braintree_marketplace_merchant_account, class: MerchantAccount::BraintreeMarketplaceMerchantAccount do
      data { { 'bank_routing_number' => '110000000', 'bank_account_number' => '000123456789', 'date_of_birth' => '1986-10-08' } }
      payment_gateway { FactoryGirl.create(:braintree_marketplace_payment_gateway) }
    end
  end
end
