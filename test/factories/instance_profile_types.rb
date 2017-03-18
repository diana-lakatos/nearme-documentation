FactoryGirl.define do
  factory :instance_profile_type do
    sequence(:name) { |n| "Default" }
    profile_type { InstanceProfileType::DEFAULT }
    instance { PlatformContext.current.instance || FactoryGirl.create(:instance) }

    after(:create) do |ipt|
      Utils::FormComponentsCreator.new(ipt).create!
    end

    factory :seller_profile_type do
      name 'Seller'
      profile_type { InstanceProfileType::SELLER }
    end

    factory :buyer_profile_type do
      name 'Buyer'
      profile_type { InstanceProfileType::BUYER }
    end
  end
end
