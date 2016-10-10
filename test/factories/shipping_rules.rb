FactoryGirl.define do
  factory :shipping_rule do
    instance_id 1
    name 'MyString'
    shipping_profile_id 1
    price_cents 1
    processing_time 'MyString'
    is_worldwide false
  end
end
