FactoryGirl.define do
  factory :instance_client do
    association(:client, :factory => :user)
  end
end
