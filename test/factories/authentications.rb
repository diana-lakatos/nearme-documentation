FactoryGirl.define do
  factory :authentication do
    association :user
    provider 'twitter'
    sequence(:uid) { |n| "uid #{n}" }
    sequence(:token) { |n| "token#{n}" }
    profile_url 'http://twitter.com/someone'

    factory :authentication_linkedin do
      provider "linkedin"
      uid "123545"
      profile_url 'http://linkedin.com/someone'
    end
  end

end
