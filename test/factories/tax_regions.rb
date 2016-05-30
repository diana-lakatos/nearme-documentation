FactoryGirl.define do
  factory :tax_region do
    country { Country.find_by_iso("US") || FactoryGirl.build(:country) }
  end
end
