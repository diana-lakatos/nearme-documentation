FactoryGirl.define do
  factory :_tax_rate do
    association :tax_region
    value 23
    included_in_price true
    name "VAT"
    default true

    factory :california_state_tax_rate do
      state { State.find_by_abbr("CA") || FactoryGirl.build(:state) }
      calculate_with :replace
      value 13
    end

  end
end
