FactoryGirl.define do
  factory :payment do

    paid_at { Time.zone.now }
    subtotal_amount_cents { 100_00 }
    service_fee_amount_guest_cents { 10_00 }
    payment_gateway_mode :test
    state 'pending'
    currency 'USD'
    association(:payment_method, factory: :credit_card_payment_method)

    factory :manual_payment do
      association(:payment_method, factory: :manual_payment_method)
    end

    factory :remote_payment do
      state 'authorized'
      association(:payment_method, factory: :remote_payment_method)
    end

    factory :pending_payment do
      after(:build) do |payment, evaluator|
        payment.payable = evaluator.payable || FactoryGirl.build(:reservation, payment: payment)
      end
    end

    factory :payment_unpaid do
      paid_at nil
    end

    factory :authorized_payment do
      state 'authorized'

      after(:build) do |payment, evaluator|
        payment.payable = evaluator.payable || FactoryGirl.build(:unconfirmed_reservation, payment: payment)
        payment.billing_authorizations = [FactoryGirl.build(:billing_authorization, payment: payment, reference: payment.payable)]
      end
    end

    factory :paid_payment do
      state 'paid'

      after(:build) do |payment, evaluator|
        payment.payable = evaluator.payable || FactoryGirl.build(:confirmed_reservation, payment: payment)
        payment.charges = [FactoryGirl.build(:charge, payment: payment)]
      end
    end


    factory :refunded_payment do
      state 'refunded'
      after(:build) do |payment, evaluator|
        payment.payable = evaluator.payable || FactoryGirl.create(:cancelled_by_guest_reservation, payment: payment)
        payment.refunds = [FactoryGirl.create(:refund, payment: payment)]
      end
    end

    factory :product_payment do
      subtotal_amount_cents { 50_00 }
      service_fee_amount_guest_cents { 5_00 }

      after(:build) do |payment, evaluator|
        payment.payable = evaluator.payable || FactoryGirl.create(:completed_order_with_totals)
      end

      factory :authorized_product_payment do
        state 'authorized'

        after(:build) do |payment, evaluator|
          payment.payable = evaluator.payable || FactoryGirl.create(:completed_order_with_totals)
          payment.billing_authorizations = [FactoryGirl.build(:billing_authorization, payment: payment, reference: payment.payable)]
        end
      end

      factory :paid_product_payment do
        state 'paid'

        after(:build) do |payment, evaluator|
          payment.payable = evaluator.payable || FactoryGirl.create(:completed_order_with_totals)
          payment.charges = [FactoryGirl.build(:charge, payment: payment)]
        end
      end


      factory :payment_order_unpaid do
        paid_at nil
      end
    end
  end
end
