FactoryGirl.define do
  factory :instance do
    sequence(:name) { |n| Instance.first ? "desks near me #{n}" : 'DesksNearMe' }
    bookable_noun 'Desk'
    lessor 'host'
    lessee 'guest'

    facebook_consumer_key 'fb1'
    facebook_consumer_secret 'fb2'
    twitter_consumer_key 't1'
    twitter_consumer_secret 't2'
    linkedin_consumer_key 'li1'
    linkedin_consumer_secret 'li2'
    instagram_consumer_key 'i1'
    instagram_consumer_secret 'i2'

    twilio_consumer_key 'tc1'
    twilio_consumer_secret 'tc2'
    twilio_from_number '501'

    test_twilio_consumer_key 'test_tc1'
    test_twilio_consumer_secret 'test_tc2'
    test_twilio_from_number 'test_501'

    tt_select_type 'dropdown'

    seller_attachments_access_level 'all'

    after(:create) do |instance, _evaluator|
      instance.theme = FactoryGirl.create(:theme, owner: instance, instance_id: instance.id) unless instance.theme
      unless Domain.find_by_name('example.com').present?
        instance.domains = [FactoryGirl.create(:test_domain, target: instance, instance_id: instance.id)]
      end
      MarketplaceBuilderSettings.create!(instance_id: instance.id, manifest: {}, status: 'ready') unless instance.marketplace_builder_settings
    end

    factory :instance_test_mode do
      test_mode true
      password_protected true
      marketplace_password '123456'
    end

    factory :instance_require_verification do
      after(:build) do |instance|
        approval_request_template = FactoryGirl.build(:approval_request_template, owner_type: 'User')
        instance.approval_request_templates = [approval_request_template]
      end
    end
  end
end
