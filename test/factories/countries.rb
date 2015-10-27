FactoryGirl.define do
  factory :country do
    iso_name "UNITED STATES"
    iso "US"
    iso3 "USA"
    name "United States"
    numcode 840
    states_required true
    calling_code "1"

    factory :country_us do
    end

    factory :country_pl do
      iso_name "POLAND"
      iso "PL"
      iso3 "POL"
      name "Poland"
      numcode 616
      states_required true
      calling_code "48"
    end

    factory :country_nz do
      iso_name "NEW ZEALAND"
      iso "NZ"
      iso3 "NZL"
      name "New Zealand"
      numcode 554
      states_required true
      calling_code "64"
    end

    factory :country_gb do
      iso_name "UNITED KINGDOM"
      iso "GB"
      iso3 "GBR"
      name "United Kingdom"
      numcode 826
      states_required true
      instance_id nil
      company_id nil
      partner_id nil
      user_id nil
      calling_code "44"
    end
  end
end
