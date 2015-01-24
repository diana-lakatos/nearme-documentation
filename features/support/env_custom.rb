$:.push(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test')))

require 'email_spec'
require 'email_spec/cucumber'
require 'factory_girl'
require "json_spec/cucumber"
require 'helpers/gmaps_fake'

DatabaseCleaner.strategy = :truncation

Before do
  DatabaseCleaner.clean
  WebMock.disable_net_connect!
  GmapsFake.stub_requests
  stub_request(:get, /.*api\.mixpanel\.com.*/)
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
  FactoryGirl.create(:paypal_payment_gateway)
  FactoryGirl.create(:stripe_payment_gateway)
  FactoryGirl.create(:balanced_payment_gateway)
  FactoryGirl.create(:fetch_payment_gateway)
  FactoryGirl.create(:braintree_payment_gateway)

  ActiveMerchant::Billing::Base.mode = :test
  Billing::Gateway::Processor::Incoming::Stripe.any_instance.stubs(:authorize).returns({token: "token", payment_gateway_class: "Billing::Gateway::Processor::Incoming::Stripe"})
  Billing::Gateway::Processor::Incoming::Paypal.any_instance.stubs(:authorize).returns({token: "token", payment_gateway_class: "Billing::Gateway::Processor::Incoming::Paypal"})
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

  ipg = FactoryGirl.create(:stripe_instance_payment_gateway)
  instance.instance_payment_gateways << FactoryGirl.create(:paypal_instance_payment_gateway)

  instance.instance_payment_gateways << ipg

  country_ipg = FactoryGirl.create(
    :country_instance_payment_gateway,
    country_alpha2_code: "US",
    instance_payment_gateway_id: ipg.id
  )
  instance.country_instance_payment_gateways << country_ipg
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
