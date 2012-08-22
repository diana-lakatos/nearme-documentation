FactoryGirl.define do
  factory :location do
    address "42 Wallaby Way"
    name "P. Sherman's Smilehouse"
    email "psherman@smilehouse.com"
    description "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    latitude "-33.856944"
    longitude "151.215278"
    creator
    company

    factory :private_location do
      after(:create) do |l|
        l.organizations << FactoryGirl.create(:organization)
      end
      require_organization_membership true
    end
    factory :location_in_auckland do
      name "Auckland Meuseum"
      address "Parnell, Auckland 1010 New Zealand"
      latitude "-36.858675"
      longitude "174.777303"
      association(:company, factory: :company_in_auckland)
    end
    factory :location_in_cleveland do
      name "Rock and Roll Hall of Fame"
      address "1100 Rock and Roll Boulevard"
      latitude "41.508806"
      longitude "-81.69548"
      association(:company, factory: :company_in_cleveland)
    end

    factory :location_in_san_francisco do
      name "Golden Gate Bridge"
      address "Golden Gate Bridge"
      latitude "37.819959"
      longitude "-122.478696"
      association(:company, factory: :company_in_san_francisco)
    end

    factory :location_in_wellington do
      name "35 Ghuznee Street"
      address "35 Ghuznee Street"
      latitude "-41.293597"
      longitude "174.7763361"
      association(:company, factory: :company_in_wellington)
    end
  end
end
