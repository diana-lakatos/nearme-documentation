require 'test_helper'

class InstanceTest < ActiveSupport::TestCase

  should validate_presence_of(:name)

  setup do
    @instance = Instance.default_instance
  end

  context 'stripe supported' do
    setup do
      @instance.stripe_api_key = 'a'
      @instance.stripe_public_key = 'b'
    end

    should 'support stripe if has all necessary details' do
      assert @instance.stripe_supported?
    end

    should 'not support stripe without api key' do
      @instance.stripe_api_key = ''
      refute @instance.stripe_supported?
    end

    should 'not support stripe without public key' do
      @instance.stripe_public_key = ''
      refute @instance.stripe_supported?
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

  context 'test mode' do
    should 'should use live credentials when off' do
      @instance.test_mode = false

      assert_equal 'john_live',       @instance.paypal_username
      assert_equal 'pass_live',       @instance.paypal_password
      assert_equal '123_live',        @instance.paypal_client_id
      assert_equal 'secret_live',     @instance.paypal_client_secret
      assert_equal 'sig_live',        @instance.paypal_signature
      assert_equal 'app-123_live',    @instance.paypal_app_id
      assert_equal 'live-public-key', @instance.stripe_public_key
      assert_equal 'live-api-key',    @instance.stripe_api_key
    end

    should 'use test credentials' do
      @instance.test_mode = true

      assert_equal 'john_test',       @instance.paypal_username
      assert_equal 'pass_test',       @instance.paypal_password
      assert_equal '123_test',        @instance.paypal_client_id
      assert_equal 'secret_test',     @instance.paypal_client_secret
      assert_equal 'sig_test',        @instance.paypal_signature
      assert_equal 'app-123_test',    @instance.paypal_app_id
      assert_equal 'test-public-key', @instance.stripe_public_key
      assert_equal 'test-api-key',    @instance.stripe_api_key
    end
  end

  context 'billing gateway' do

    setup do
      @instance = FactoryGirl.create(:instance)
    end

    should 'return instance custom credentials for Stripe if not set in application config' do
      assert_equal @instance.stripe_api_key, @instance.billing_gateway_credential('stripe_api_key')
      assert_equal @instance.stripe_public_key, @instance.billing_gateway_credential('stripe_public_key') 
    end

    should 'return credentials for Stripe set in application config' do
      DesksnearMe::Application.config.stubs('stripe_api_key').returns('api-key')
      DesksnearMe::Application.config.stubs('stripe_public_key').returns('public-key')

      assert_equal 'api-key', @instance.billing_gateway_credential('stripe_api_key')
      assert_equal 'public-key', @instance.billing_gateway_credential('stripe_public_key')
      assert_not_equal @instance.stripe_api_key, @instance.billing_gateway_credential('stripe_api_key')
      assert_not_equal @instance.stripe_public_key, @instance.billing_gateway_credential('stripe_public_key') 
    end
  end
end
