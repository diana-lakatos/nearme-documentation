require 'test_helper'

class InstanceTest < ActiveSupport::TestCase

  should validate_presence_of(:name)

  setup do
    @instance = Instance.default_instance
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

  context 'domain validation' do
    should 'not allow to remove the only domain' do
      instance = FactoryGirl.create(:instance)
      domain = FactoryGirl.build(:domain, target: instance)
      instance.domains = [domain]
      instance.save!
      refute domain.destroy
    end

    should 'allow to remove domain of other exists' do
      instance = FactoryGirl.create(:instance)
      domain = FactoryGirl.build(:domain, target: instance)
      instance.domains = [domain, FactoryGirl.build(:domain, target: instance)]
      instance.save!
      assert domain.destroy
    end
  end

end
