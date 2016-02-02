FactoryGirl.define do
  factory :reservation_request do
    quantity 1
    dates { Date.today.next_week.to_s }
    start_minute 600
    end_minute 900
    country_name "Great Britan"
    mobile_number '666 666 666'
    reservation_type 'daily'

    payment {
      {
        payment_method: FactoryGirl.build(:credit_card_payment_method),
        credit_card_form: FactoryGirl.attributes_for(:credit_card_form)
      }
    }

    factory :reservation_request_with_not_valid_cc do
       payment {
        {
          payment_method: FactoryGirl.build(:credit_card_payment_method),
          credit_card_form: FactoryGirl.attributes_for(:failed_credit_card_form)
        }
      }
    end
  end
end
