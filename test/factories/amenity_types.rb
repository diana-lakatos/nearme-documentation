FactoryGirl.define do

  factory :amenity_type do
    sequence(:name) do |n|
      "Amenity Type #{n}"
    end

  end
end
