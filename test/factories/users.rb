FactoryGirl.define do
  factory :user do
    email { "#{name.to_s.downcase.underscore}@example.com" }
    password 'password'
    password_confirmation 'password'
    phone "1234567890"
    instance

    sequence(:name) {|n| "User-#{n}"}

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
