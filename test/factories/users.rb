FactoryGirl.define do
  factory :user do
    email { "#{name.to_s.downcase.underscore}@example.com" }
    password 'password'
    password_confirmation 'password'
    country_name "United States"
    phone "1234567890"
    mobile_number "1234567890"
    instance
    job_title "Manager"
    biography "I'm cool!"

    sequence(:name) {|n| "User-#{n}"}

    factory :user_without_country_name do
      country_name nil
    end

    factory :admin do
      admin true
    end

    factory :creator do
      sequence(:name) {|n| "Creator-#{n}"}
    end

    factory :authenticated_user do
      sequence(:name) {|n| "Authenticated-User-#{n}"}
      authentication_token "EZASABC123UANDME"
    end
  end

end
