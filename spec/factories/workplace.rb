Factory.define :workplace do |w|
  w.name { "Somewhere Else" }
  w.address "1 York St Launceston TAS 7250"
  w.description { Faker::Lorem.paragraphs(2).join }
  w.company_description { Faker::Lorem.paragraph }
  w.confirm_bookings true
  w.maximum_desks 3
  w.association :creator, :factory => :user
end
