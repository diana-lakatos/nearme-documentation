FactoryGirl.define do
  factory :user do
    email { "#{name.to_s.downcase.underscore}@example.com" }
    password 'password'
    password_confirmation 'password'

    sequence(:name) {|n| "User-#{n}"}

    factory :admin do
      admin true
    end

    factory :creator do
      sequence(:name) {|n| "Creator-#{n}"}
    end
  end

end
