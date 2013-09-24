FactoryGirl.define do
  factory :domain do
    sequence(:name) {|n| "desksnear#{n}.me" }
    target_type "Instance"
    target_id { (Instance.default_instance.presence || FactoryGirl.create(:instance)).id }
  end
end
