FactoryGirl.define do
  factory :authentication do
    user
    provider 'twitter'
    sequence(:uid) { |n| "uid #{n}" }
    sequence(:token) { |n| "token#{n}" }
    profile_url 'http://twitter.com/someone'
    token_expired false
    token_expires_at { Time.zone.now + 1.month }

    factory :authentication_linkedin do
      provider 'linkedin'
      uid '123545'
      profile_url 'http://linkedin.com/someone'
    end
  end
end
