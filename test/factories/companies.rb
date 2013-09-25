FactoryGirl.define do
  factory :company do
    sequence(:name) { |n| "Company #{n}" }
    sequence(:email) { |n| "company-#{n}@example.com" }
    description "Aliquid eos ab quia officiis sequi."
    creator
    url "http://google.com"
    instance_id { (Instance.default_instance.presence || FactoryGirl.create(:instance)).id }

    after(:build) do |company|
      company.industries = [FactoryGirl.build(:industry)] if company.industries.empty?
    end

    after(:create) do |company|
      company.users = [company.creator] if company.creator.present?
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

    factory :company_with_paypal_email do
      paypal_email { email }
    end

    factory :white_label_company do
      white_label_enabled true
    end
  end
end

