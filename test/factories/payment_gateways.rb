FactoryGirl.define do
  factory :payment_gateway do
    name "PaymentGateway"
    settings { {api_key: "present"} }

    factory :balanced_payment_gateway do
      name "Balanced"
      settings { {api_key: "present"} }
    end

    factory :paypal_payment_gateway do
      name "PayPal"
      settings {
        {
          email: '',
          username: '',
          password: '',
          client_id: '',
          client_secret: '',
          signature: '',
          app_id: ''
        }
      }
    end

    factory :stripe_payment_gateway do
      name "Stripe"
      settings {
        {
          public_key: '',
          api_key: ''
        }
      }
    end
  end  
end
