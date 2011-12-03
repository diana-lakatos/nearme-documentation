Factory.define :workplace do |w|
  w.name { "Somewhere Else" }
  w.address { "#{(rand * 99 + 1).to_i} York St Launceston TAS 7250" }
  w.latitude { -34.705022 + (rand * 0.02 - 0.01) }
  w.longitude { 138.710672 + (rand * 0.02 - 0.01) }
  w.description { Faker::Lorem.paragraphs(2).join }
  w.company_description { Faker::Lorem.paragraph }
  w.confirm_bookings true
  w.maximum_desks 3
  w.association :creator, :factory => :user
end
