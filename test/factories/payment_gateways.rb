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
  end  
end
