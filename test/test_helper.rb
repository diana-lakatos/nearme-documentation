# frozen_string_literal: true
ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'
SimpleCov.start if ENV['COVERAGE']

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/autorun'
# require 'minitest/reporters'
require 'mocha/setup'
require 'mocha/mini_test'
require 'webmock/minitest'
require 'backtrace_filter'
require 'ffaker'

require Rails.root.join('test', 'helpers', 'stub_helper.rb')

reporter_options = { color: true, slow_count: 5 }
Minitest.backtrace_filter = BacktraceFilter.new
Minitest::Reporters.use!(Minitest::Reporters::DefaultReporter.new(reporter_options), ENV, Minitest.backtrace_filter)

RoutingFilter.active = false
ActiveMerchant::Billing::Base.mode = :test
WebMock.disable_net_connect!(allow: /localhost:9200/)

# Disable carrierwave processing in tests
# It can be enabled on a per-test basis as needed.
CarrierWave.configure do |config|
  config.enable_processing = false
end

module Rack
  module Test
    class UploadedFile
      attr_reader :tempfile
    end
  end
end

ActiveSupport::TestCase.class_eval do
  ActiveRecord::Migration.check_pending!

  include FactoryGirl::Syntax::Methods
  include StubHelper

  setup do
    DatabaseCleaner.clean # needed :/
    TestDataSeeder.seed!
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
    PlatformContext.current = PlatformContext.new(Instance.first || FactoryGirl.create(:instance))
  end

  def current_instance
    PlatformContext.current.instance
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

  def action_type_attibutes(options)
    pricings = if options[:prices]
                 options[:prices].each.with_index.each_with_object({}) do |values, result|
                   price, index = values
                   result[index.to_s] = {
                     enabled: '1',
                     transactable_type_pricing_id: TransactableType.first.time_based_booking.pricing_for(price[0].to_s).try(:id),
                     price: price[1],
                     number_of_units: price[0].to_s.split('_').first,
                     unit: price[0].to_s.split('_').last
                   }
                   result
                 end
               else
                 {
                   '0' => {
                     transactable_type_pricing_id: TransactableType.first.time_based_booking.pricing_for('1_day').id,
                     enabled: '1',
                     price: 0,
                     number_of_units: 1,
                     unit: 'day',
                     is_free_booking: true
                   }
                 }
    end

    {
      action_types_attributes: {
        '0' => {
          transactable_type_action_type_id: TransactableType.first.action_types.first.id,
          enabled: 'true',
          type: options[:type] || 'Transactable::TimeBasedBooking',
          pricings_attributes: pricings
        }
      }
    }
  end

  def assert_contains(expected, object, message = nil)
    message ||= "Expected #{expected.inspect} to be included in #{object.inspect}"
    assert object.to_s.include?(expected), message
  end

  def assert_not_contains(unexpected, object, message = nil)
    message ||= "Unexpected #{unexpected.inspect} in #{object.inspect}"
    refute object.to_s.include?(unexpected), message
  end

  def with_carrier_wave_processing(&_blk)
    before = CarrierWave::Uploader::Base.enable_processing
    CarrierWave::Uploader::Base.enable_processing = true
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
    request.headers['Authorization'] = @user.authentication_token
  end

  def set_authentication_header(user = nil)
    user ||= FactoryGirl.create(:authenticated_user)
    user.ensure_authentication_token!
    request.headers['UserAuthorization'] = user.authentication_token
  end

  def mailer_stub
    stub(deliver: true)
  end

  def stub_billing_gateway(instance)
    FactoryGirl.create(:stripe_payment_gateway, instance_id: instance.id)
  end

  def process_credit_card!(credit_card)
    credit_card.response = nil
    credit_card.instance_client.update_attribute(:encrypted_response, nil)
    credit_card.instance_client.send(:clear_decorator)
    credit_card.attributes = FactoryGirl.attributes_for(:credit_card_attributes).reject { |k, _v| k == :response }
    credit_card.process!
    credit_card.save!
  end

  def stub_active_merchant_interaction(response = { success?: true })
    PaymentGateway.any_instance.stubs(:gateway_authorize).returns(OpenStruct.new(response.reverse_merge(authorization: '54533')))
    PaymentGateway.any_instance.stubs(:gateway_purchase).returns(OpenStruct.new(response.reverse_merge(authorization: '54533')))
    PaymentGateway.any_instance.stubs(:gateway_void).returns(OpenStruct.new(response.reverse_merge(authorization: '54533')))
    PaymentGateway.any_instance.stubs(:gateway_capture).returns(OpenStruct.new(response.reverse_merge(params: { 'id' => '12345' })))
    PaymentGateway.any_instance.stubs(:gateway_purchase).returns(OpenStruct.new(response.reverse_merge(params: { 'id' => '12345' })))
    PaymentGateway.any_instance.stubs(:gateway_refund).returns(OpenStruct.new(response.reverse_merge(params: { 'id' => '12345' })))
    PaymentGateway::StripePaymentGateway.any_instance.stubs(:find_balance).returns(
      OpenStruct.new(id: '1', status: 'succeeded', fee_details: [OpenStruct.new(type: 'stripe_fee', amount: 10)])
    )
    PayPal::SDK::AdaptivePayments::API.any_instance.stubs(:pay).returns(OpenStruct.new(response.reverse_merge(paymentExecStatus: 'COMPLETED')))

    stub_store_card
  end

  def stub_store_card
    stub = OpenStruct.new(success?: true, params: {
                            'object' => 'customer',
                            'id' => 'customer_1',
                            'default_source' => 'card_1',
                            'cards' => {
                              'data' => [
                                { 'id' => 'card_1' }
                              ]
                            }
                          })
    PaymentGateway.any_instance.stubs(:gateway_store).returns(stub).at_least(0)
  end

  # def mock_transactable_prices(transactable, options = [])
  #   pricings = options.map{|o| stub(o)}
  #   transactable.action_type.stubs(:pricings).returns(pricings)
  # end

  def wait_for_elastic_index
    sleep 2
  end

  def build_default_cancellation_policy_for(record)
    if record.instance_of?(Transactable)
      record.action_types.where(type: 'Transactable::TimeBasedBooking').each do |at|
        create_cancellation_policies(at.transactable_type_action_type)
      end
    end
  end
end

def create_cancellation_policies(cancellable, options = {})
  FactoryGirl.create(:cancel_allowed_cellation_policy, cancellable: cancellable)
  FactoryGirl.create(:cancelled_by_host_refund_cellation_policy, (options[:host_refund_options] || {}).reverse_merge(cancellable: cancellable) )
  FactoryGirl.create(:cancelled_by_guest_refund_cellation_policy,  (options[:guest_refund_options] || {}).reverse_merge(cancellable: cancellable) )
end

ActionController::TestCase.class_eval do
  include Rails.application.routes.url_helpers
  include Devise::TestHelpers

  setup :return_default_host

  def return_default_host
    request.host =  'example.com'
  end

  def self.logged_in(factory = :admin, &block)
    context 'logged in as {factory}' do
      setup do
        @user = FactoryGirl.create(factory)
        sign_in @user
      end

      merge_block(&block) if block_given?
    end
  end

  def with_versioning
    was_enabled = PaperTrail.enabled?
    was_enabled_for_controller = PaperTrail.enabled_for_controller?
    PaperTrail.enabled = true
    PaperTrail.enabled_for_controller = true
    begin
      yield
    ensure
      PaperTrail.enabled = was_enabled
      PaperTrail.enabled_for_controller = was_enabled_for_controller
    end
  end

  def spree
    Spree::Core::Engine.routes.url_helpers
  end
end

ActionMailer::Base.delivery_method = :test # Spree overrides this so we want to get back to test
DatabaseCleaner.clean_with :truncation
DatabaseCleaner.strategy = :transaction

class TestDataSeeder
  @@data_seeded = false

  def self.seed!
    unless @@data_seeded
      @@data_seeded = true
      instance = FactoryGirl.create(:instance)
      instance.set_context!
      instance.build_availability_templates
      instance.save!
      Utils::FormComponentsCreator.new(instance).create!

      FactoryGirl.create(:transactable_type_listing, generate_rating_systems: true)
      FactoryGirl.create(:country_us)
      FactoryGirl.create(:country_pl)
      FactoryGirl.create(:instance_profile_type)
      FactoryGirl.create(:primary_locale)
      FactoryGirl.create(:seller_profile_type)
      FactoryGirl.create(:buyer_profile_type)
      FactoryGirl.create(:user_message_type)
    end
  end
end

class DummyEvent < WorkflowStep::BaseStep
end

def enable_elasticsearch!(&_block)
  Rails.application.config.use_elastic_search = true

  instance = Instance.last

  engine = Elastic::Engine.new
  builder = Elastic.default_index_name_builder(instance)
  index_type = Elastic::IndexTypes::MultipleModel.new(sources: [User, Transactable])

  Elastic::IndexZero.new(type: index_type, version: 0, builder: builder).tap do |index|
    engine.create_index index unless engine.index_exists? index.alias_name
  end

  yield if block_given?

  Transactable.__elasticsearch__.refresh_index!
end

def disable_elasticsearch!
  Elasticsearch::Model.client.indices.delete index: 'test-*'
  Rails.application.config.use_elastic_search = false
end

# see https://github.com/rails/rails-dom-testing/issues/48
# fixes frozen string literal in assert_select
# can't upgrade gem because it would require upgrading
# rails to 5.0
class SubstitutionContext
  def substitute_with_dup!(selector, *args)
    substitute_without_dup!(selector.dup, *args)
  end
  alias_method_chain :substitute!, :dup
end
