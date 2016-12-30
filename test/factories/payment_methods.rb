FactoryGirl.define do
  factory :payment_method do
    factory :credit_card_payment_method, class: 'PaymentMethod::CreditCardPaymentMethod' do
      payment_gateway { FactoryGirl.create(:stripe_payment_gateway) }
      payment_method_type 'credit_card'
      type 'PaymentMethod::CreditCardPaymentMethod'
    end

    factory :manual_payment_method, class: 'PaymentMethod::ManualPaymentMethod' do
      payment_gateway { FactoryGirl.create(:manual_payment_gateway) }
      payment_method_type 'manual'
      type 'PaymentMethod::ManualPaymentMethod'

    end

    factory :remote_payment_method, class: 'PaymentMethod::RemotePaymentMethod' do
      payment_gateway { FactoryGirl.create(:fetch_payment_gateway) }
      payment_method_type 'remote'
      type 'PaymentMethod::RemotePaymentMethod'
    end

    factory :paypal_express_payment_method, class: 'PaymentMethod::ExpressCheckoutPaymentMethod' do
      payment_gateway { FactoryGirl.create(:paypal_express_payment_gateway) }
      payment_method_type 'express_checkout'
      type 'PaymentMethod::ExpressCheckoutPaymentMethod'
    end
  end
end
