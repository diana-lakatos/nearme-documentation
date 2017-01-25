FactoryGirl.define do
  factory :paypal_account do
    association :instance_client
    association :payment_method, factory: :paypal_express_payment_method
    response { OpenStruct.new(token: 'token', success?: true, params: { "object": 'card', "id": 'card_1234' }).to_yaml }
  end
end
