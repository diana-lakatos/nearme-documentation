FactoryGirl.define do

  factory :listing_type do
    sequence(:name) do |n|
      "Listing Type #{n}"
    end

  end
end
