FactoryGirl.define do
  factory :workplace do
    name { "Somewhere Else" }
    address { "#{(rand * 99 + 1).to_i} York St Launceston TAS 7250" }
    latitude { -34.705022 + (rand * 0.02 - 0.01) }
    longitude { 138.710672 + (rand * 0.02 - 0.01) }
    description { Faker::Lorem.paragraphs(2).join }
    company_description { Faker::Lorem.paragraph }
    confirm_bookings true
    maximum_desks 3
    association :creator, :factory => :user
  end
end
