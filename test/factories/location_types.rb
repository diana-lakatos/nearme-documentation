FactoryGirl.define do

  factory :location_type do
    sequence(:name) { |n| "Location Type #{n}" }
    instance { (Instance.default_instance || FactoryGirl.create(:instance)) }
  end
end
