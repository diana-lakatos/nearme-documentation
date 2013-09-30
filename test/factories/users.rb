FactoryGirl.define do
  factory :user do
    email { "#{name.to_s.underscore.downcase.tr(' ', '_')}@example.com" }
    password 'password'
    password_confirmation 'password'
    country_name "United States"
    phone "18889983375"
    mobile_number "18889983375"
    job_title "Manager"
    biography "I'm cool!"
    current_location "Prague"
    company_name "DesksNearMe"
    skills_and_interests { Faker::Lorem.sentences(2) }

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

    factory :demo_user do
      avatar { fixture_file_upload(Dir.glob(Rails.root.join('db', 'seeds', 'demo', 'assets', 'avatars', '*')).sample, 'image/jpeg') }
      avatar_versions_generated_at Time.zone.now
    end
  end

end
