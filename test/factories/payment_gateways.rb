FactoryGirl.define do
  factory :payment_gateway do
    test_settings { {api_key: "present"} }
    live_settings { {api_key: "present"} }

    factory :paypal_payment_gateway, class: PaymentGateway::PaypalPaymentGateway do
      test_settings {
        {
          email: 'sender_test@example.com',
          login: 'john_test',
          password: 'pass_test',
          signature: 'sig_test',
          app_id: 'app-123_test'
        }
      }
      live_settings {
        {
          email: 'sender_live@example.com',
          login: 'john_live',
          password: 'pass_live',
          signature: 'sig_live',
          app_id: 'app-123_live'
        }
      }
    end

    factory :stripe_payment_gateway, class: PaymentGateway::StripePaymentGateway do
      test_settings { { login: 'sk_test_r0wxkPFASg9e45UIakAhgpru' } }
      live_settings { { login: 'sk_test_r0wxkPFASg9e45UIakAhgpru' } }
    end

    factory :fetch_payment_gateway, class: PaymentGateway::FetchPaymentGateway do
      test_settings { { account_id: '123456789', secret_key: '987654321' } }
      live_settings { { account_id: '123456789', secret_key: '987654321' } }
    end

    factory :braintree_payment_gateway, class: PaymentGateway::BraintreePaymentGateway do
      type 'PaymentGateway::BraintreePaymentGateway'
      test_settings { { merchant_id: "123456789", public_key: "987654321", private_key: "321543", supported_currency: 'USD'} }
      live_settings { { merchant_id: "123456789", public_key: "987654321", private_key: "321543", supported_currency: 'USD'} }
    end

    factory :braintree_marketplace_payment_gateway, class: PaymentGateway::BraintreeMarketplacePaymentGateway do
      type 'PaymentGateway::BraintreeMarketplacePaymentGateway'
      test_settings { { merchant_id: "123456789", public_key: "987654321", private_key: "321543", supported_currency: 'USD', master_merchant_account_id: 'master_id'} }
      live_settings { { merchant_id: "123456789", public_key: "987654321", private_key: "321543", supported_currency: 'USD', master_merchant_account_id: 'master_id'} }
    end
  end
end

