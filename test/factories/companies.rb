FactoryGirl.define do
  factory :company do
    sequence(:name) { |n| "Company #{n}" }
    sequence(:email) { |n| "company-#{n}@example.com" }
    description "Aliquid eos ab quia officiis sequi."
    creator
    instance
    url "http://google.com"

    before(:create) do |company|
      company.industries << FactoryGirl.create(:industry) if company.industries.empty?
    end

    factory :company_in_auckland do
      name "Company in Auckland"
    end

    factory :company_in_adelaide do
      name "Company in Adelaide"
    end

    factory :company_in_cleveland do
      name "Company in Cleveland"
    end

    factory :company_in_san_francisco do
      name "Company in San Francisco"
    end

    factory :company_in_wellington do
      name "Company in Wellington"
    end

  end
end
