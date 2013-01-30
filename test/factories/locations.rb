FactoryGirl.define do
  factory :location do
    address "42 Wallaby Way"
    name "P. Sherman's Smilehouse"
    email "psherman@smilehouse.com"
    description "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    latitude "-33.856944"
    longitude "151.215278"
    availability_template_id "M-F9-5"
    company

    factory :location_in_auckland do
      name "Auckland Meuseum"
      address "Parnell, Auckland 1010 New Zealand"
      latitude "-36.858675"
      longitude "174.777303"
      association(:company, factory: :company_in_auckland)
    end

    factory :location_in_adelaide do
      name "Adelaide Meuseum"
      address "Adelaide"
      latitude "-41.4391386"
      longitude "147.1405474"
      association(:company, factory: :company_in_adelaide)
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
