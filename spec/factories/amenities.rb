FactoryGirl.define do
  factory :amenity do
    sequence(:name) { |n| name { "Amenity #{n}" } }
  end
end
