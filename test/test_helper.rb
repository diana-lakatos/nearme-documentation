require 'rubygems'
require 'spork'
Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  unless ENV['DRB']
    require 'simplecov'
  end
  ENV["RAILS_ENV"] ||= "test"

  require 'rails/application'

  if Spork.using_spork?
    Spork.trap_method(Rails::Application, :eager_load!)
    Spork.trap_method(Rails::Application::RoutesReloader, :reload!)
    Spork.trap_method(Rails::Application, :reload_routes!)
    Rails.application.railties.all { |r| r.eager_load! }
  end

  require File.expand_path('../../config/environment', __FILE__)

  require 'rails/test_help'
  require 'turn'
  require 'mocha/setup'
  require 'mocha/integration/test_unit'
  require 'webmock/test_unit'

  require Rails.root.join('test', 'helpers', 'stub_helper.rb')

  Turn.config.format = :dot

  # Disable carrierwave processing in tests
  # It can be enabled on a per-test basis as needed.
  CarrierWave.configure do |config|
    config.enable_processing = false
  end

  class ActiveSupport::TestCase
    # Add more helper methods to be used by all tests here...
    include FactoryGirl::Syntax::Methods
    include StubHelper

    def with_carrier_wave_processing(&blk)
      before, CarrierWave::Uploader::Base.enable_processing = CarrierWave::Uploader::Base.enable_processing, true
      yield
    ensure
      CarrierWave::Uploader::Base.enable_processing = before
    end

    def assert_contains(expected, object, message = nil)
      message ||= "Expected #{expected.inspect} to be included in #{object.inspect}"
      assert object.to_s.include?(expected), message
    end

    def raw_post(action, params, body)
      # The problem with doing this is that the JSON sent to the app
      # is that Rails will parse and put the JSON payload into params.
      # But this approach doesn't behave like that for tests.
      # The controllers are doing more work by parsing JSON than necessary.
      @request.env['RAW_POST_DATA'] = body
      response = post(action, params)
      @request.env.delete('RAW_POST_DATA')
      response
    end

    def raw_put(action, params, body)
      @request.env['RAW_POST_DATA'] = body
      response = put(action, params)
      @request.env.delete('RAW_POST_DATA')
      response
    end

    def authenticate!
      @user = FactoryGirl.create(:authenticated_user)
      request.env['Authorization'] = @user.authentication_token
    end

    def assert_log_triggered(*args)
      stub_mixpanel
      @tracker.expects(event).with do
        yield(*args)
      end
    end

    def assert_log_not_triggered(event)
      stub_mixpanel
      @tracker.expects(event).never
    end

    def stub_mixpanel
      stub_request(:get, /.*api\.mixpanel\.com.*/)
      @tracker = Analytics::EventTracker.any_instance
    end

    def mailer_stub
      stub(deliver: true)
    end

    def stub_billing_gateway
      User::BillingGateway.any_instance.stubs(:charge).returns(true)
      User::BillingGateway.any_instance.stubs(:store_card).returns(true)
    end

    DatabaseCleaner.strategy = :truncation

  end

  class ActionController::TestCase

    include Devise::TestHelpers

    def self.logged_in(factory = :admin, &block)

      context "logged in as {factory}" do

        setup do
          @user = FactoryGirl.create(factory)
          sign_in @user
        end

        merge_block(&block) if block_given?
      end

    end
  end

end

Spork.each_run do
  # This code will be run each time you run your specs.
  if ENV['DRB']
    require 'simplecov'
  end

  class ActiveSupport::TestCase
    setup :setup_platform_context

    def setup_platform_context
      FactoryGirl.create(:theme)
    end
  end

  FactoryGirl.reload
  DatabaseCleaner.clean
end

