FactoryGirl.define do
  factory :reservation_request do
    quantity 1
    dates { Date.today.next_week.to_s }
    start_minute 600
    end_minute 900
    card_holder_first_name "Rowan"
    card_holder_last_name "Atkinson"
    card_exp_month 1
    card_exp_year  { Date.today.year + 2 }
    card_code "111"
    card_number "4111111111111111"
    country_name "Great Britan"
    mobile_number '666 666 666'
    payment_method_id { payment_method.id }
    reservation_type 'daily'

    factory :reservation_request_with_not_valid_cc do
      card_number "123 123 123 123"
    end
  end
end
