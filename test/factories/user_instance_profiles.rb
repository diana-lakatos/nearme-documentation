FactoryGirl.define do
  factory :user_instance_profile do
    user
    instance { Instance.first || FactoryGirl.create(:instance) }
    instance_profile_type
  end
end
