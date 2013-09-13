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
  store_model("instance", nil, FactoryGirl.create(:instance))
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
