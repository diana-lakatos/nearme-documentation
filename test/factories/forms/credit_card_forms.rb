FactoryGirl.define do
  factory :credit_card_form do
    first_name "Rowan"
    last_name "Atkinson"
    number "4111111111111111"
    month 1
    year  { Date.today.year + 2 }
    verification_value "111"

    factory :failed_credit_card_form do
      number "123 123 123 12"
    end
  end
end
