FactoryGirl.define do
  factory :credit_card do
    association :instance_client
    payment_method { PaymentMethod::CreditCardPaymentMethod.last || build(:credit_card_payment_method) }
    response { OpenStruct.new(token: 'token', success?: true, params: { "object": 'card', "id": 'card_1234' }).to_yaml }

    factory :credit_card_attributes do
      first_name 'Rowan'
      last_name 'Atkinson'
      number '4111111111111111'
      month 1
      year  { Date.today.year + 2 }
      verification_value '111'

      factory :invalid_credit_card_attributes do
        response nil
        number '123'
      end
    end
  end
end
