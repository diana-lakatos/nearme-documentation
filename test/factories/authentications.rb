FactoryGirl.define do
  factory :authentication do
    association :user
    provider 'twitter'
    sequence(:uid) { |n| "uid #{n}" }
    sequence(:token) { |n| "token#{n}" }

    factory :authentication_linkedin do
      provider "linkedin"
      uid "123545"
    end
  end

end
