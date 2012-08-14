FactoryGirl.define do
  factory :company do
    sequence(:name) { |n| "Company #{n}" }
    creator
    url "http://google.com"

    factory :company_in_auckland do	
      name "Company in Auckland"
    end

    factory :company_in_cleveland do
      name "Company in Cleveland"
    end

    factory :company_in_san_francisco do
      name "Company in San Francisco"
    end

  end
end
