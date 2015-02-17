# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :country_instance_payment_gateway do
    country_alpha2_code "US"
    instance_payment_gateway_id 1
    instance { Instance.first }

    factory :fetch_country_instance_payment_gateway do
      instance_payment_gateway_id { FactoryGirl.create(:fetch_instance_payment_gateway).id }
      country_alpha2_code "NZ"
      instance { Instance.first }
    end
  end
end
