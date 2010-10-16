Factory.define :workplace do |w|
  w.name "Somewhere Else"
  w.address "1 York St Launceston TAS 7250"
  w.latitude { Faker::Geolocation.lat }
  w.longitude { Faker::Geolocation.lng }
  w.description { Faker::Lorem.paragraphs(2) }
  w.company_description { Faker::Lorem.paragraphs(1) }
  w.confirm_bookings true
  w.maximum_desks 3
end
