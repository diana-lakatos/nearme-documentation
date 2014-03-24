FactoryGirl.define do

  factory :instance do
    sequence(:name) {|n| Instance.default_instance ? "desks near me #{n}" : 'DesksNearMe'}
    default_instance false
    bookable_noun 'Desk'
    lessor 'host'
    lessee 'guest'
    service_fee_guest_percent '10.00'
    service_fee_host_percent '10.00'
    paypal_email 'sender_live@example.com'

    live_paypal_username 'john_live'
    live_paypal_password 'pass_live'
    live_paypal_client_id '123_live'
    live_paypal_client_secret 'secret_live'
    live_paypal_signature 'sig_live'
    live_paypal_app_id 'app-123_live'
    live_stripe_public_key 'live-public-key'
    live_stripe_api_key 'live-api-key'

    facebook_consumer_key 'fb1'
    facebook_consumer_secret 'fb2'
    twitter_consumer_key 't1'
    twitter_consumer_secret 't2'
    linkedin_consumer_key 'li1'
    linkedin_consumer_secret 'li2'
    instagram_consumer_key 'i1'
    instagram_consumer_secret 'i2'

    test_paypal_username 'john_test'
    test_paypal_password 'pass_test'
    test_paypal_client_id '123_test'
    test_paypal_client_secret 'secret_test'
    test_paypal_signature 'sig_test'
    test_paypal_app_id 'app-123_test'
    test_stripe_public_key 'test-public-key'
    test_stripe_api_key 'test-api-key'

    after(:create) do |instance|
      instance.theme = FactoryGirl.create(:theme, :skip_compilation => true) unless instance.theme
    end

    factory :default_instance do
      default_instance true
    end

    factory :instance_with_price_constraints do
      min_hourly_price 10
      max_hourly_price 100
    end

    factory :instance_with_balanced do
      balanced_api_key 'present'
    end
  end

end
