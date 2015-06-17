# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :country_payment_gateway do
    country_alpha2_code "US"
    payment_gateway { FactoryGirl.create(:stripe_payment_gateway) }
    instance { Instance.first }

    factory :fetch_country_payment_gateway do
      payment_gateway { FactoryGirl.create(:fetch_payment_gateway) }
      country_alpha2_code "NZ"
      instance { Instance.first }
    end
  end
end
