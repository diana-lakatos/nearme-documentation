# frozen_string_literal: true
require 'test_helper'

class ReencryptAllDataTest < ActiveSupport::TestCase
  context 'reencrypt:all_data Task' do
    setup do
      @old_key = DesksnearMe::Application.config.secret_token
    end

    should 'Reencrypts data in db' do
      instance = FactoryGirl.create(:instance, facebook_consumer_key: 'secret_123')
      gateway = FactoryGirl.create(:paypal_payment_gateway, instance_id: instance.id)
      old_fb = instance.facebook_consumer_key
      old_live_settings = gateway.live_settings
      old_encrypted_live_settings = gateway.encrypted_live_settings

      DesksnearMe::Application.config.secret_token = 'new_secret_token'
      Rake::Task['reencrypt:all_data'].invoke(@old_key)
      DesksnearMe::Application.config.secret_token = 'new_secret_token'

      assert_equal old_fb, instance.reload.facebook_consumer_key
      assert_equal old_live_settings, gateway.reload.live_settings
      assert_not_equal old_encrypted_live_settings, gateway.encrypted_live_settings
    end

    teardown do
      DesksnearMe::Application.config.secret_token = @old_key
    end
  end
end
