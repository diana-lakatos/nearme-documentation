FactoryGirl.define do
  factory :state do
    country { Country.find_by_iso('US') || FactoryGirl.build(:country) }
    name 'California'
    abbr 'CA'
  end
end
