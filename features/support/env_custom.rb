# frozen_string_literal: true
$LOAD_PATH.push(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test')))

require 'email_spec'
require 'email_spec/cucumber'
require 'factory_girl'
require 'json_spec/cucumber'
require 'helpers/gmaps_fake'
require_relative 'minitest_setup'

Capybara::Webkit.configure do |config|
  config.allow_url('http://maps.googleapis.com/*')
  config.allow_url('http://csi.gstatic.com/*')
  config.allow_url('https://rawgit.com/mdyd-dev/marketplaces/*')
  config.allow_url('https://*.cloudfront.net/*')
  config.allow_url('https://js.stripe.com/v2/*')
  config.allow_url('https://api.stripe.com/v1/tokens')
  config.block_unknown_urls
  # Uncomment if you want to debug JavaScript
  # config.debug = true
end

Before do
  DatabaseCleaner.clean
  if defined?(ENV['ALLOW_CONNECTIONS'])
    WebMock.allow_net_connect!
  else
    WebMock.disable_net_connect!(allow_localhost: true)
  end
  GmapsFake.stub_requests
  stub_request(:post, 'https://www.googleapis.com/urlshortener/v1/url')
  stub_request(:get, 'https://www.filepicker.io/api/file/-nBq2onTSemLBxlcBWn1').to_return(status: 200, body: File.read(Rails.root.join('test', 'assets', 'foobear.jpeg')), headers: { 'Content-Type' => 'image/jpeg' })
  stub_request(:get, 'http://static.ak.facebook.com')

  instance = FactoryGirl.create(:instance)
  FactoryGirl.create(:domain, target: instance, instance_id: instance.id, name: '127.0.0.1')
  FactoryGirl.create(:domain, target: instance, instance_id: instance.id, name: 'example.org')
  store_model('instance', nil, instance)
  store_model('theme', nil, instance.theme)
  instance.set_context!

  Utils::FormComponentsCreator.new(instance).create!
  FactoryGirl.create(:instance_profile_type)
  FactoryGirl.create(:seller_profile_type)
  FactoryGirl.create(:buyer_profile_type)
  FactoryGirl.create(:primary_locale)
  FactoryGirl.create(:instance)

  I18N_DNM_BACKEND.update_cache(instance.id) if defined? I18N_DNM_BACKEND
  InstanceViewResolver.instance.clear_cache

  %w(default lister enquirer).each do |role|
    FactoryGirl.create(:"form_configuration_#{role}_signup")
  end
  FactoryGirl.create(:form_configuration_default_update_minimum)
end

After do
  ::CustomAttributes::CustomAttribute::CacheDataHolder.clear_all_cache!
end

Before('@fake_payments') do
  ActiveMerchant::Billing::Base.mode = :test
  response = { success?: true }
  PaymentGateway.any_instance.stubs(:gateway_authorize).returns(OpenStruct.new(response.reverse_merge(authorization: 'token ')))
  PaymentGateway.any_instance.stubs(:gateway_void).returns(OpenStruct.new(response.reverse_merge(authorization: '54533')))
  PaymentGateway.any_instance.stubs(:gateway_capture).returns(OpenStruct.new(response.reverse_merge(params: { 'id' => '12345' })))
  PaymentGateway.any_instance.stubs(:gateway_purchase).returns(OpenStruct.new(response.reverse_merge(params: { 'id' => '12345' })))
  PaymentGateway.any_instance.stubs(:gateway_refund).returns(OpenStruct.new(response.reverse_merge(params: { 'id' => '12345' })))
  PayPal::SDK::AdaptivePayments::API.any_instance.stubs(:pay).returns(OpenStruct.new(response.reverse_merge(paymentExecStatus: 'COMPLETED')))
  PaymentGateway::StripePaymentGateway.any_instance.stubs(:find_balance).returns(
    OpenStruct.new({ id: '1', status: 'succeeded', fee_details: [OpenStruct.new(type: 'stripe_fee', amount: 10)] })
  )
  stub = OpenStruct.new(success?: true, params: {
                          'object' => 'customer',
                          'id' => 'customer_1',
                          'cards' => {
                            'data' => [
                              { 'id' => 'card_1' }
                            ]
                          }
                        })
  ActiveMerchant::Billing::StripeGateway.any_instance.stubs(:store).returns(stub).at_least(0)

  FactoryGirl.create(:stripe_payment_gateway)
  FactoryGirl.create(:paypal_adaptive_payment_gateway)
end

Before('@elasticsearch') do
  Rails.application.config.use_elastic_search = true
  Transactable.indexer_helper.create_base_index
  User.indexer_helper.create_base_index
  Transactable.indexer_helper.create_alias
  User.indexer_helper.create_alias
  Transactable.searchable.import
end

After('@elasticsearch') do
  Transactable.__elasticsearch__.client.indices.delete_alias name: Transactable.alias_index_name, index: Transactable.base_index_name
  User.__elasticsearch__.client.indices.delete_alias name: User.alias_index_name, index: User.base_index_name
  Transactable.__elasticsearch__.client.indices.delete index: Transactable.base_index_name
  User.__elasticsearch__.client.indices.delete index: User.base_index_name
  Rails.application.config.use_elastic_search = false
end

After do |_scenario, _block|
  travel_back
end

def last_json
  last_response.body
end

World(Rails.application.routes.url_helpers)
World(Rack::Test::Methods)

require 'webmock/rspec'
World(WebMock::API, WebMock::Matchers)
OmniAuth.config.test_mode = true
