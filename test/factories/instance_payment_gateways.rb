FactoryGirl.define do
  factory :instance_payment_gateway do
    instance_id 1
    payment_gateway_id 1
    test_settings { {api_key: "present"} }
    live_settings { {api_key: "present"} }

    factory :balanced_instance_payment_gateway do
      payment_gateway_id { PaymentGateway.balanced.id }
      test_settings { {api_key: "ak-test-eyoGATiAg6YE5thvhSiWIi7NE0zg0l0U"} }
      live_settings { {api_key: "ak-test-eyoGATiAg6YE5thvhSiWIi7NE0zg0l0U"} }
    end

    factory :paypal_instance_payment_gateway do
      payment_gateway_id { PaymentGateway.paypal.id }
      test_settings {
        {
          email: 'sender_test@example.com',
          username: 'john_test',
          password: 'pass_test',
          client_id: '123_test',
          client_secret: 'secret_test',
          signature: 'sig_test',
          app_id: 'app-123_test'
        }
      }
      live_settings {
        {
          email: 'sender_live@example.com',
          username: 'john_live',
          password: 'pass_live',
          client_id: '123_live',
          client_secret: 'secret_live',
          signature: 'sig_live',
          app_id: 'app-123_live'
        }
      }
    end

    factory :stripe_instance_payment_gateway do
      payment_gateway_id { PaymentGateway.stripe.id }
      test_settings {
        {
          public_key: 'pk_test_epSwdfDLmuIxAyUGx1LvoEki',
          api_key: 'sk_test_r0wxkPFASg9e45UIakAhgpru',
          currency: 'USD'
        }
      }
      live_settings {
        {
          public_key: 'pk_test_epSwdfDLmuIxAyUGx1LvoEki',
          api_key: 'sk_test_r0wxkPFASg9e45UIakAhgpru',
          currency: 'USD'
        }
      }
    end
  end
end
