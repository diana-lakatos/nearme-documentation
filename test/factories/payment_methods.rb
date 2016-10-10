FactoryGirl.define do
  factory :payment_method do
    factory :credit_card_payment_method do
      payment_gateway { FactoryGirl.create(:stripe_payment_gateway) }
      payment_method_type 'credit_card'
    end

    factory :manual_payment_method do
      payment_gateway { FactoryGirl.create(:manual_payment_gateway) }
      payment_method_type 'manual'
    end

    factory :remote_payment_method do
      payment_gateway { FactoryGirl.create(:fetch_payment_gateway) }
      payment_method_type 'remote'
    end

    factory :paypal_express_payment_method do
      payment_gateway { FactoryGirl.create(:paypal_express_payment_gateway) }
      payment_method_type 'express_checkout'
    end
  end
end
