# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :instance_billing_gateway do
    instance_id { (Instance.default_instance.presence || FactoryGirl.create(:instance)).id }
    billing_gateway "stripe"
    currency "USD"
  end
end
