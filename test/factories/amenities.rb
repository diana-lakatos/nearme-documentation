FactoryGirl.define do
  factory :amenity do
    sequence(:name) { |n|  "Amenity #{n}" }
  end
end
