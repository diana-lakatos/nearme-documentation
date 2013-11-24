FactoryGirl.define do

  factory :location_type do
    sequence(:name) { |n| "Location Type #{n}" }
    instance_id { (Instance.default_instance.presence || FactoryGirl.create(:instance)).id }
  end
end
