# frozen_string_literal: true
FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "User-#{n} User" }
    sequence(:email) { |n| "#{name.to_s.underscore.downcase.tr(' ', '_')}_#{n}@example.com" }
    password 'password'
    password_confirmation 'password'
    country_name 'United States'
    phone '18889983375'
    mobile_number '18889983375'
    association :current_address, factory: :address_czestochowa
    company_name 'DesksNearMe'
    last_geolocated_location_longitude 14.437800
    last_geolocated_location_latitude 50.075538
    sms_notifications_enabled false
    sms_preferences { Hash[%w(user_message reservation_state_changed new_reservation).map { |sp| [sp, '1'] }] }
    instance_unread_messages_threads_count { {} }
    instance_profile_type { InstanceProfileType.default.first || FactoryGirl.create(:instance_profile_type) }

    after(:create) do |u|
      if u.last_name.blank?
        u.last_name = 'User'
        u.save!
      end
    end

    factory :user_without_country_name do
      country_name nil
    end

    factory :user_with_sms_notifications_enabled do
      sms_notifications_enabled true
    end

    factory :admin do
      admin true
    end

    factory :creator do
      sequence(:name) { |n| "Creator-#{n} User" }
    end

    factory :authenticated_user do
      sequence(:name) { |n| "Authenticated-User-#{n} User" }
      authentication_token 'EZASABC123UANDME'
    end

    factory :demo_user do
      avatar { fixture_file_upload(Dir.glob(Rails.root.join('test', 'assets', 'foobear.jpeg')).sample, 'image/jpeg') }
      avatar_versions_generated_at Time.zone.now
    end

    factory :user_without_password do
      after(:create) do |u|
        u.encrypted_password = ''
        u.save!(validate: false)
      end
    end

    factory :user_with_verified_phone_number do
      communication
    end

    factory :enquirer, aliases: [:driver] do
      after(:build, &:get_buyer_profile)

      factory :registered_enquirer do
        after(:build) do |u|
          u.buyer_profile.categories << Category.roots.map { |c| c.children.first }
        end
      end
    end

    factory :lister, aliases: [:passenger] do
      sms_notifications_enabled true
      after(:build, &:get_seller_profile)
    end
  end
end
