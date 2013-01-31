FactoryGirl.define do

  factory :location_type do
    sequence(:name) do |n|
      "Location Type #{n}"
    end

  end
end
