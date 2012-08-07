FactoryGirl.define do
  factory :location do
    address "42 Wallaby Way"
    name "P. Shermans Smilehouse"
    latitude "-33.856944"
    longitude "151.215278"
    creator
    company

    factory :location_in_auckland do
      name "Auckland Meuseum"
      address "Parnell, Auckland 1010 New Zealand"
      latitude "-36.858675"
      longitude "174.777303"
    end
    factory :location_in_cleveland do
      name "Rock and Roll Hall of Fame"
      address "1100 Rock and Roll Boulevard"
      latitude "41.508806"
      longitude "-81.69548"
    end

    factory :location_in_san_francisco do
      name "Golden Gate Bridge"
      address "Golden Gate Bridge"
      latitude "37.819959"
      longitude "-122.478696"
    end
  end
end
