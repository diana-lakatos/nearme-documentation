require 'test_helper'

class InstanceTest < ActiveSupport::TestCase
  context 'stripe_api_key' do
    setup do
      @instance = Instance.default_instance
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
      @instance = Instance.default_instance
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
end
