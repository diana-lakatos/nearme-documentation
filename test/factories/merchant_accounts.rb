FactoryGirl.define do
  factory :merchant_account do
    association(:merchantable, factory: :company)
    payment_gateway { FactoryGirl.create(:stripe_payment_gateway) }
    state 'verified'
    data { {} }

    factory :paypal_merchant_account, class: MerchantAccount::PaypalMerchantAccount do
      payment_gateway { FactoryGirl.create(:paypal_payment_gateway) }
      data { { 'email' => 'receiver@example.com' } }
    end

    factory :paypal_adaptive_merchant_account, class: MerchantAccount::PaypalAdaptiveMerchantAccount do
      payment_gateway { FactoryGirl.create(:paypal_adaptive_payment_gateway) }
      data { { 'email' => 'receiver@example.com' } }
    end

    factory :paypal_express_chain_merchant_account, class: MerchantAccount::PaypalExpressChainMerchantAccount do
      payment_gateway { FactoryGirl.create(:paypal_express_chain_payment_gateway) }
    end

    factory :braintree_marketplace_merchant_account, class: MerchantAccount::BraintreeMarketplaceMerchantAccount do
      data { { 'bank_routing_number' => '110000000', 'bank_account_number' => '000123456789', 'date_of_birth' => '1986-10-08', 'first_name' => 'Maciek', 'last_name' => 'Krajowski', 'street_address' => 'my cool address 2B', 'region' => 'Mazowieckie', 'locality' => 'Warsaw', 'postal_code' => '2334' } }
      payment_gateway { FactoryGirl.create(:braintree_marketplace_payment_gateway) }
    end

    factory :stripe_connect_merchant_account, class: 'MerchantAccount::StripeConnectMerchantAccount' do
      after(:build) do |merchant_account|
        merchant_account.owners = FactoryGirl.build_list(:stripe_connect_merchant_account_owner, 1, merchant_account: merchant_account)
      end
      data { { 'business_tax_id' => '440-94-3290', 'bank_routing_number' => '110000000', 'bank_account_number' => '000123456789', 'account_type' => 'company' } }
      payment_gateway { FactoryGirl.create(:stripe_connect_payment_gateway) }
      personal_id_number '440-94-3290'

      factory :failed_stripe_connect_merchant_account do
        data { {
          disabled_reason: 'This account is rejected for some other reason.',
          verification_message: 'Scan failed for other reason.',
          fields_needed: ['legal_entity.verification.document']
        } }
        state 'failed'
      end
    end

  end
end
