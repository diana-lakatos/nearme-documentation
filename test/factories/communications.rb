FactoryGirl.define do
  factory :communication do
    provider 'twilio'
    provider_key { SecureRandom.hex(15) }
    phone_number '+00000000000'
    phone_number_key { SecureRandom.hex(15) }
    request_key { SecureRandom.hex(15) }
    verified true
  end
end
