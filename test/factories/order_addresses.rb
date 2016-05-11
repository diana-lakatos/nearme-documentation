FactoryGirl.define do
  factory :order_address do
    firstname "Tomasz"
    lastname "Lemkowski"
    company 'NearMe'
    street1 '185 CLARA STREET #102D'
    city 'SAN FRANCISCO'
    zip '94107'
    phone '1234567890'
    email 'lemkowski@gmail.com'
    state_name 'California'
    country { Country.first || FactoryGirl.create(:country) }
    state { State.first || FactoryGirl.create(:state) }
    # association :state
    association :user
    # association :shippo
  end
end
