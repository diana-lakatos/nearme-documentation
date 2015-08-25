$:.push(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test')))

require 'email_spec'
require 'email_spec/cucumber'
require 'factory_girl'
require 'spree/testing_support/factories'
require "json_spec/cucumber"
require 'helpers/gmaps_fake'
require_relative 'minitest_setup'

DatabaseCleaner.strategy = :truncation

Before do
  DatabaseCleaner.clean
  WebMock.disable_net_connect!
  GmapsFake.stub_requests
  stub_request(:get, /.*api\.mixpanel\.com.*/)
  stub_request(:get, /.*mixpanel\.com\/api.*/).to_return(body: "[]")
  stub_request(:post, "https://www.googleapis.com/urlshortener/v1/url")
  stub_request(:get, 'https://www.filepicker.io/api/file/-nBq2onTSemLBxlcBWn1').to_return(:status => 200,:body => File.read(Rails.root.join("test", "assets", "foobear.jpeg")), :headers => {'Content-Type' => 'image/jpeg'})
  stub_request(:get, 'http://static.ak.facebook.com')
  instance = FactoryGirl.create(:instance)
  FactoryGirl.create(:domain, target: instance, name: "127.0.0.1")
  FactoryGirl.create(:domain, target: instance, name: "example.org")
  store_model("instance", nil, instance)
  store_model("theme", nil, instance.theme)
  Thread.current[:platform_context] = PlatformContext.new(instance)
  FactoryGirl.create(:instance)

  ActiveMerchant::Billing::Base.mode = :test

  PaymentAuthorizer.any_instance.stubs(:gateway_authorize).returns(OpenStruct.new(success?: true, authorization: "token "))

  stub = OpenStruct.new(params: {
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
  Transactable.clear_custom_attributes_cache
  User.clear_custom_attributes_cache
  Spree::Product.clear_custom_attributes_cache
end

def last_json
  last_response.body
end

World(Rails.application.routes.url_helpers)
World(Rack::Test::Methods)

require 'webmock/rspec'
World(WebMock::API, WebMock::Matchers)
WebMock.disable_net_connect!(:allow_localhost => true)
OmniAuth.config.test_mode = true
