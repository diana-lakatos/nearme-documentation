FactoryGirl.define do
  factory :instance_payment_gateway do
    instance_id 1
    payment_gateway_id 1
    test_settings { {api_key: "present"} }
    live_settings { {api_key: "present"} }

    factory :balanced_instance_payment_gateway do
      payment_gateway_id { PaymentGateway.where(method_name: "balanced").first.id }
      test_settings { {login: "ak-test-eyoGATiAg6YE5thvhSiWIi7NE0zg0l0U"} }
      live_settings { {login: "ak-test-eyoGATiAg6YE5thvhSiWIi7NE0zg0l0U"} }
    end

    factory :paypal_instance_payment_gateway do
      payment_gateway_id { PaymentGateway.where(method_name: "paypal").first.id }
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

    factory :stripe_instance_payment_gateway do
      payment_gateway_id { PaymentGateway.where(method_name: "stripe").first.id }
      test_settings { { login: 'sk_test_r0wxkPFASg9e45UIakAhgpru' } }
      live_settings { { login: 'sk_test_r0wxkPFASg9e45UIakAhgpru' } }
    end

    factory :fetch_instance_payment_gateway do
      payment_gateway_id { FactoryGirl.create(:fetch_payment_gateway).id }
      test_settings { { account_id: '123456789', secret_key: '987654321' } }
      live_settings { { account_id: '123456789', secret_key: '987654321' } }
    end
  end
end
