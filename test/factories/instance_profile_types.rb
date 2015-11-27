FactoryGirl.define do
  factory :instance_profile_type do
    sequence(:name) {|n| "Instance Profile Type #{n}"}
    profile_type { InstanceProfileType::DEFAULT }
    instance { PlatformContext.current.instance || FactoryGirl.create(:instance) }

    factory :seller_profile_type do
      profile_type { InstanceProfileType::SELLER }

      after(:build) do |instance_profile_type|
        instance_profile_type.form_components << FactoryGirl.build(:form_component_instance_profile_type_seller, form_componentable: instance_profile_type)
      end
    end

    factory :buyer_profile_type do
      profile_type { InstanceProfileType::BUYER }

      after(:build) do |instance_profile_type|
        instance_profile_type.form_components << FactoryGirl.build(:form_component_instance_profile_type_buyer, form_componentable: instance_profile_type)
      end

    end

    after(:build) do |instance_profile_type|
      InstanceProfileType.transaction do
        instance_profile_type.form_components << FactoryGirl.build(:form_component_instance_profile_type, form_componentable: instance_profile_type) if instance_profile_type.form_components.blank?
      end
    end
  end
end
