require 'test_helper'

class InstanceTest < ActiveSupport::TestCase

  setup do
    @instance = Instance.default_instance
  end
  context 'stripe_api_key' do
    setup do
      @default_key = Stripe.api_key = "testkey"
    end

    should 'fallback to env default' do
      assert_equal @default_key, @instance.custom_stripe_api_key
    end

    should 'use instance key' do
      key = "mytestkey"
      @instance.update_attribute(:stripe_api_key, key)
      assert_equal key, @instance.custom_stripe_api_key
    end
  end

  context 'stripe_public_key' do
    setup do
      @default_key = DesksnearMe::Application.config.stripe_public_key = "testkey"
    end

    should 'fallback to env default' do
      assert_equal @default_key, @instance.custom_stripe_public_key
    end

    should 'use instance key' do
      key = "mytestkey"
      @instance.update_attribute(:stripe_public_key, key)

      assert_equal key, @instance.custom_stripe_public_key
    end
  end

  context 'paypal supported' do
    setup do
      @instance.paypal_username = 'a'
      @instance.paypal_password = 'b'
      @instance.paypal_signature =  'c'
      @instance.paypal_client_id = 'd'
      @instance.paypal_client_secret = 'e'
      @instance.paypal_app_id = 'f'
    end

    should 'support paypal if has all necessary details' do
      assert @instance.paypal_supported?
    end

    should 'not support paypal without username' do
      @instance.paypal_username = ''
      refute @instance.paypal_supported?
    end

    should 'not support paypal without password' do
      @instance.paypal_password = ''
      refute @instance.paypal_supported?
    end

    should 'not support paypal without signature' do
      @instance.paypal_client_id = ''
      refute @instance.paypal_supported?
    end

    should 'not support paypal without client_secret' do
      @instance.paypal_client_secret = ''
      refute @instance.paypal_supported?
    end

    should 'not support paypal without app_id' do
      @instance.paypal_app_id = ''
      refute @instance.paypal_supported?
    end

  end

  context 'balanced_supported?' do

    should 'support balanced if has specified api' do
      @instance.balanced_api_key = '123'
      assert @instance.balanced_supported?
    end

    should 'not support balanced if has not specified api' do
      @instance.balanced_api_key = ''
      refute @instance.balanced_supported?
    end

  end

  context 'support_automated_payouts?' do

    should 'not be supported if both balanced and paypal are not available' do
      @instance.stubs(:balanced_supported?).returns(false).at_least(0)
      @instance.stubs(:paypal_supported?).returns(false).at_least(0)
      refute @instance.support_automated_payouts?
    end
    
    should 'be supported paypal is available' do
      @instance.stubs(:balanced_supported?).returns(false).at_least(0)
      @instance.stubs(:paypal_supported?).returns(true).at_least(0)
      assert @instance.support_automated_payouts?
    end

    should 'be supported balanced is supported' do
      @instance.stubs(:paypal_supported?).returns(false).at_least(0)
      @instance.stubs(:balanced_supported?).returns(true).at_least(0)
      assert @instance.support_automated_payouts?
    end

    should 'be supported if both balanced and paypal are supported' do
      @instance.stubs(:paypal_supported?).returns(true).at_least(0)
      @instance.stubs(:balanced_supported?).returns(true).at_least(0)
      assert @instance.support_automated_payouts?
    end

  end

end
