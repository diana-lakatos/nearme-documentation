$:.push(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test')))

require 'email_spec'
require 'email_spec/cucumber'
require 'factory_girl'
require "json_spec/cucumber"
require 'helpers/gmaps_fake'
require_relative 'minitest_setup'

Capybara::Webkit.configure do |config|
  config.allow_url("http://maps.googleapis.com/*")
  config.allow_url("http://csi.gstatic.com/*")
  config.block_unknown_urls
end

Before do
  DatabaseCleaner.clean
  WebMock.disable_net_connect!(:allow_localhost => true)
  GmapsFake.stub_requests
  stub_request(:post, "https://www.googleapis.com/urlshortener/v1/url")
  stub_request(:get, 'https://www.filepicker.io/api/file/-nBq2onTSemLBxlcBWn1').to_return(:status => 200,:body => File.read(Rails.root.join("test", "assets", "foobear.jpeg")), :headers => {'Content-Type' => 'image/jpeg'})
  stub_request(:get, 'http://static.ak.facebook.com')

  instance = FactoryGirl.create(:instance)
  FactoryGirl.create(:domain, target: instance, instance_id: instance.id, name: "127.0.0.1")
  FactoryGirl.create(:domain, target: instance, instance_id: instance.id, name: "example.org")
  store_model("instance", nil, instance)
  store_model("theme", nil, instance.theme)
  instance.set_context!

  Utils::FormComponentsCreator.new(instance).create!
  FactoryGirl.create(:instance_profile_type)
  FactoryGirl.create(:seller_profile_type)
  FactoryGirl.create(:buyer_profile_type)
  FactoryGirl.create(:primary_locale)
  FactoryGirl.create(:instance)

  ActiveMerchant::Billing::Base.mode = :test

  response={success?: true}
  PaymentGateway.any_instance.stubs(:gateway_authorize).returns(OpenStruct.new(response.reverse_merge({authorization: "token "})))
  PaymentGateway.any_instance.stubs(:gateway_void).returns(OpenStruct.new(response.reverse_merge({authorization: "54533"})))
  PaymentGateway.any_instance.stubs(:gateway_capture).returns(OpenStruct.new(response.reverse_merge({params: {"id" => '12345'}})))
  PaymentGateway.any_instance.stubs(:gateway_refund).returns(OpenStruct.new(response.reverse_merge({params: {"id" => '12345'}})))
  PayPal::SDK::AdaptivePayments::API.any_instance.stubs(:pay).returns(OpenStruct.new(response.reverse_merge(paymentExecStatus: "COMPLETED")))


  stub = OpenStruct.new(success?: true, params: {
    "object" => 'customer',
    "id" => 'customer_1',
    "cards" => {
      "data" => [
        { "id" => "card_1" }
      ]
    }
  })
  ActiveMerchant::Billing::StripeGateway.any_instance.stubs(:store).returns(stub).at_least(0)

  FactoryGirl.create(:stripe_payment_gateway)
  FactoryGirl.create(:paypal_adaptive_payment_gateway)

  I18N_DNM_BACKEND.update_cache(instance.id) if defined? I18N_DNM_BACKEND
  InstanceViewResolver.instance.clear_cache
end

After do
  ::CustomAttributes::CustomAttribute::CacheDataHolder.clear_all_cache!
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

After do |scenario, block|
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
