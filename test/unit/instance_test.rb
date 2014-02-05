require 'test_helper'

class InstanceTest < ActiveSupport::TestCase

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

end
