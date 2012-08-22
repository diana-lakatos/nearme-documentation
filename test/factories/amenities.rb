FactoryGirl.define do
  factory :amenity do
    sequence(:name) { |n| "Amenity #{n}" }
    factory :wifi do
      name "Wi-Fi"
    end
  end
end
