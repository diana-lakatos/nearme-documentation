require 'test_helper'

class MigrateInstancePaymentGatewaySettingsTest < ActiveSupport::TestCase

  context 'migrate settings' do
    setup do
      @instance = Instance.default_instance
      setup_old_credentials
      load File.expand_path("../../../lib/tasks/migrate_instance_payment_gateway_settings.rake", __FILE__)
      Rake::Task.define_task(:environment)
      Rake::Task["migrate_instance_payment_gateway_settings:start"].invoke
    end

    should 'assert that settings where migrated correctly' do
      assert_equal @instance.instance_payment_gateways.get_settings_for(:stripe, :login, :test), "test_stripe_api_key"
      assert_equal @instance.instance_payment_gateways.get_settings_for(:stripe, :login, :live), "live_stripe_api_key"
      assert_equal @instance.instance_payment_gateways.get_settings_for(:balanced, :login, :test), "test_balanced_api_key"
      assert_equal @instance.instance_payment_gateways.get_settings_for(:balanced, :login, :live), "live_balanced_api_key"
      assert_equal @instance.instance_payment_gateways.get_settings_for(:paypal, :email, :test), "paypal_email"
      assert_equal @instance.instance_payment_gateways.get_settings_for(:paypal, :email, :live), "paypal_email"
      assert_equal @instance.instance_payment_gateways.get_settings_for(:paypal, :login, :test), "test_paypal_username"
      assert_equal @instance.instance_payment_gateways.get_settings_for(:paypal, :login, :live), "live_paypal_username"
      assert_equal @instance.instance_payment_gateways.get_settings_for(:paypal, :password, :live), "live_paypal_password"
      assert_equal @instance.instance_payment_gateways.get_settings_for(:paypal, :password, :test), "test_paypal_password"
      assert_equal @instance.instance_payment_gateways.get_settings_for(:paypal, :signature, :live), "live_paypal_signature"
      assert_equal @instance.instance_payment_gateways.get_settings_for(:paypal, :signature, :test), "test_paypal_signature"
      assert_equal @instance.instance_payment_gateways.get_settings_for(:paypal, :app_id, :test), "test_paypal_app_id"
      assert_equal @instance.instance_payment_gateways.get_settings_for(:paypal, :app_id, :live), "live_paypal_app_id"

      assert_equal @instance.country_instance_payment_gateways.where(instance_id: @instance.id).count, PaymentGateway.countries.count
    end
  end

  def setup_old_credentials
    @instance.test_stripe_api_key = "test_stripe_api_key"
    @instance.test_stripe_public_key = "test_stripe_public_key"
    @instance.live_stripe_api_key = "live_stripe_api_key"
    @instance.live_stripe_public_key = "live_stripe_public_key"
    @instance.stripe_currency = "stripe_currency"
    @instance.stripe_currency = "stripe_currency"
    @instance.test_balanced_api_key = "test_balanced_api_key"
    @instance.live_balanced_api_key = "live_balanced_api_key"
    @instance.paypal_email = "paypal_email"
    @instance.paypal_email = "paypal_email"
    @instance.test_paypal_username = "test_paypal_username"
    @instance.test_paypal_password = "test_paypal_password"
    @instance.test_paypal_signature = "test_paypal_signature"
    @instance.test_paypal_app_id = "test_paypal_app_id"
    @instance.test_paypal_client_id = "test_paypal_client_id"
    @instance.test_paypal_client_secret = "test_paypal_client_secret"
    @instance.live_paypal_username = "live_paypal_username"
    @instance.live_paypal_password = "live_paypal_password"
    @instance.live_paypal_signature = "live_paypal_signature"
    @instance.live_paypal_app_id = "live_paypal_app_id"
    @instance.live_paypal_client_id = "live_paypal_client_id"
    @instance.live_paypal_client_secret = "live_paypal_client_secret"
    @instance.save
  end

end
