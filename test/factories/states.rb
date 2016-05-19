FactoryGirl.define do
  factory :_state, class: State do
    country { Country.find_by_iso("US") || FactoryGirl.build(:country) }
    name "California"
    abbr "CA"
  end
end
