FactoryGirl.define do
  factory :instance_client do
    association(:client, :factory => :user)
    instance_id { (Instance.default_instance.presence || FactoryGirl.create(:instance)).id }
  end
end
