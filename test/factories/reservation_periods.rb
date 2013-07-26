FactoryGirl.define do
  factory :reservation_period do
    date { Time.zone.today }
  end
end
