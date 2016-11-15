# frozen_string_literal: true
FactoryGirl.define do
  factory :order_address do
    firstname 'Tomasz'
    lastname 'Lemkowski'
    company 'NearMe'
    zip '94107'
    phone '1234567890'
    email 'lemkowski@gmail.com'
    association(:address)
    country { Country.first || FactoryGirl.create(:country) }
    state { State.first || FactoryGirl.create(:state) }
    # association :state
    association :user
    # association :shippo
  end
end
