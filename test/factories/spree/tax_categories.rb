FactoryGirl.define do
  factory :tax_category, class: Spree::TaxCategory do
    name { "TaxCategory - #{rand(999999)}" }
    description { Faker::Lorem.paragraph(2) }
  end
end
