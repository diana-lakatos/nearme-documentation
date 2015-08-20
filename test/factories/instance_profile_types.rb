FactoryGirl.define do
  factory :instance_profile_type do
    sequence(:name) {|n| "Instance Profile Type #{n}"}
    instance { PlatformContext.current.instance || FactoryGirl.create(:instance) }

    after(:build) do |instance_profile_type|
      InstanceProfileType.transaction do
        instance_profile_type.form_components << FactoryGirl.build(:form_component_instance_profile_type, form_componentable: instance_profile_type)
      end
    end
  end
end
