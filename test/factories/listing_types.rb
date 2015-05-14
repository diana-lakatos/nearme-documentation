FactoryGirl.define do
  factory :listing_type do
    sequence(:name) {|n| "Location Type #{n}"}
    instance { (Instance.first || FactoryGirl.create(:instance)) }
  end
end

