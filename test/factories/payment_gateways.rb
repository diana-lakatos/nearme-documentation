FactoryGirl.define do
  factory :payment_gateway do
    name "PaymentGateway"
    settings { {api_key: "present"} }
    active_merchant_class "ActiveMerchant::Billing::BogusGateway"

    factory :balanced_payment_gateway do
      name "Balanced"
      settings { { login: "" } }
      active_merchant_class "ActiveMerchant::Billing::BalancedGateway"
    end

    factory :paypal_payment_gateway do
      name "Paypal"
      settings {
        {
          email: "",
          login: "",
          password: "",
          signature: "",
          app_id: ""
        }
      }
      active_merchant_class "ActiveMerchant::Billing::PaypalGateway"
    end

    factory :stripe_payment_gateway do
      name "Stripe"
      settings {
        {
          login: ""
        }
      }
      active_merchant_class "ActiveMerchant::Billing::StripeGateway"
    end

    factory :fetch_payment_gateway do
      name "Fetch"
      method_name 'fetch'
      settings {
        {
          account_id: "",
          secret_key: ""
        }
      }
      active_merchant_class "Billing::Gateway::Processor::Incoming::Fetch"
    end

    factory :braintree_payment_gateway do
      name "Braintree"
      settings {
        {
          merchant_id: "",
          public_key: "",
          private_key: ""
        }
      }
      active_merchant_class "ActiveMerchant::Billing::BraintreeBlueGateway"
    end

  end
end
