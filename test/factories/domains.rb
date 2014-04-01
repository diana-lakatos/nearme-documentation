FactoryGirl.define do
  factory :domain do
    sequence(:name) {|n| "desksnear#{n}.me" }
    target_type "Instance"
    target_id { (Instance.default_instance.presence || FactoryGirl.create(:instance)).id }

    factory :secured_domain do
      secured true
    end

    factory :unsecured_domain do
      secured false
    end
  end
end
