FactoryGirl.define do
  factory :amenity do
    sequence(:name) { |n| "Amenity #{n}" }
    association :amenity_type

    factory :wifi do
      name "Wi-Fi"
    end

  end
end
