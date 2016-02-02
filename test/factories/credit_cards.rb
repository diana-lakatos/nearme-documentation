FactoryGirl.define do
  factory :credit_card do
    association :instance_client
    response { 'token'}
  end
end

