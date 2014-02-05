FactoryGirl.define do

  factory :charge do
    association :user
    association(:reference, :factory => :reservation_charge)
    created_at { Time.zone.now }
    success true
    amount 1000
    currency 'USD'

    factory :charge_with_stripe_response do
      response "--- !ruby/object:Stripe::Charge\napi_key: sk_test_sPLnOkI5mvXCoUuaqi5j6djR\nvalues:\n  :id: ch_103NzV2NyQr8dJTt7gs44Xnl\n  :object: charge\n  :created: 1390821961\n  :livemode: false\n  :paid: true\n  :amount: 3555\n  :currency: usd\n  :refunded: false\n  :card: !ruby/object:Stripe::StripeObject\n    api_key: sk_test_sPLnOkI5mvXCoUuaqi5j6djR\n    values:\n      :id: card_103NzT2NyQr8dJTttFp4LbLr\n      :object: card\n      :last4: '4242'\n      :type: Visa\n      :exp_month: 8\n      :exp_year: 2015\n      :fingerprint: FqHZIMmyoSYHwLZF\n      :customer: cus_3NzTHtAfQScyAm\n      :country: US\n      :name: \n      :address_line1: \n      :address_line2: \n      :address_city: \n      :address_state: \n      :address_zip: \n      :address_country: \n      :cvc_check: pass\n      :address_line1_check: \n      :address_zip_check: \n    unsaved_values: !ruby/object:Set\n      hash: {}\n    transient_values: !ruby/object:Set\n      hash: {}\n  :captured: true\n  :refunds: []\n  :balance_transaction: txn_103NzV2NyQr8dJTtEElT79VB\n  :failure_message: \n  :failure_code: \n  :amount_refunded: 0\n  :customer: cus_3NzTHtAfQScyAm\n  :invoice: \n  :description: \n  :dispute: \n  :metadata: !ruby/object:Stripe::StripeObject\n    api_key: sk_test_sPLnOkI5mvXCoUuaqi5j6djR\n    values: {}\n    unsaved_values: !ruby/object:Set\n      hash: {}\n    transient_values: !ruby/object:Set\n      hash: {}\nunsaved_values: !ruby/object:Set\n  hash: {}\ntransient_values: !ruby/object:Set\n  hash: {}\n"  
    end

    factory :charge_with_paypal_response do

    end

    factory :charge_with_balanced_response do

    end

  end
end
