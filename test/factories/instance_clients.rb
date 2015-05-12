FactoryGirl.define do
  factory :instance_client do
    association(:client, factory: :user)
    payment_gateway { FactoryGirl.create(:stripe_payment_gateway) }
  end
end
