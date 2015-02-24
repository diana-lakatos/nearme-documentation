FactoryGirl.define do
  factory :instance_profile_type do
    sequence(:name) {|n| "Instance Profile Type #{n}"}
    instance { Instance.first.presence || FactoryGirl.create(:instance) }
  end
end
