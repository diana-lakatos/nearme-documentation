FactoryGirl.define do
  factory :reservation_request do
    quantity 1
    dates { Date.today.next_week.to_s }
    start_minute 600
    end_minute 900
    country_name "Great Britan"
    mobile_number '666 666 666'
    booking_type 'daily'

    payment_attributes {
      {
        payment_method: FactoryGirl.build(:credit_card_payment_method),
        credit_card_attributes: FactoryGirl.attributes_for(:credit_card_attributes)
      }
    }

    factory :reservation_request_with_not_valid_cc do
       payment {
        {
          payment_method: FactoryGirl.build(:credit_card_payment_method),
          credit_card_attributes: FactoryGirl.attributes_for(:invalid_credit_card_attributes)
        }
      }
    end
  end
end
