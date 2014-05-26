# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :country_instance_payment_gateway do
    country_alpha2_code "US"
    instance_payment_gateway_id 1
    instance_id 1
  end
end
