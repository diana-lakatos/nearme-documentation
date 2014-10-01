FactoryGirl.define do
  factory :user_instance_profile do
    user
    instance { Instance.default_instance || FactoryGirl.create(:instance) }
    instance_profile_type
  end
end
