require 'rubygems'
ENV["RAILS_ENV"] ||= "test"

require 'rails/application'

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
  setup :setup_platform_context

  def setup_platform_context
    FactoryGirl.create(:default_instance)
    PlatformContext.current = PlatformContext.new
  end

  def with_versioning
    was_enabled = PaperTrail.enabled?
    PaperTrail.enabled = true
    begin
      yield
    ensure
      PaperTrail.enabled = was_enabled
    end
  end

  def assert_contains(expected, object, message = nil)
    message ||= "Expected #{expected.inspect} to be included in #{object.inspect}"
    assert object.to_s.include?(expected), message
  end

  def assert_not_contains(unexpected, object, message = nil)
    message ||= "Unexpected #{unexpected.inspect} in #{object.inspect}"
    refute object.to_s.include?(unexpected), message
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

  def with_carrier_wave_processing(&blk)
    before, CarrierWave::Uploader::Base.enable_processing = CarrierWave::Uploader::Base.enable_processing, true
    yield
  ensure
    CarrierWave::Uploader::Base.enable_processing = before
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
    Billing::Gateway::Processor::Ingoing::Stripe.any_instance.stubs(:charge).returns(true)
    Billing::Gateway::Ingoing.any_instance.stubs(:store_credit_card).returns(true)
  end

  DatabaseCleaner.strategy = :truncation

end

class ActionController::TestCase

  include Devise::TestHelpers
  setup :setup_platform_context

  def setup_platform_context
    FactoryGirl.create(:default_instance)
    PlatformContext.current = PlatformContext.new
  end

  def self.logged_in(factory = :admin, &block)

    context "logged in as {factory}" do

      setup do
        @user = FactoryGirl.create(factory)
        sign_in @user
      end

      merge_block(&block) if block_given?
    end

  end

  def with_versioning
    was_enabled = PaperTrail.enabled?
    PaperTrail.enabled = true
    begin
      yield
    ensure
      PaperTrail.enabled = was_enabled
    end
  end
end

FactoryGirl.reload
DatabaseCleaner.clean
Utils::EnLocalesSeeder.new.go!
