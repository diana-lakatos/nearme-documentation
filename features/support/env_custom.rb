$:.push(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test')))

require 'email_spec'
require 'email_spec/cucumber'
require 'factory_girl'
require "json_spec/cucumber"
require 'helpers/gmaps_fake'
require 'helpers/prepare_email'

DatabaseCleaner.strategy = :truncation

Before do
  DatabaseCleaner.clean
  WebMock.disable_net_connect!
  GmapsFake.stub_requests
  FactoryGirl.create(:instance)
  stub_request(:get, /.*api\.mixpanel\.com.*/)
  stub_request(:post, "https://www.googleapis.com/urlshortener/v1/url")
end

Before('@emails') do
  mailer_stub = stub(deliver: true)
  ReservationMailer.stubs(:notify_host_with_confirmation).returns(mailer_stub)
  ReservationMailer.stubs(:notify_guest_with_confirmation).returns(mailer_stub)
  ReservationMailer.stubs(:notify_host_without_confirmation).returns(mailer_stub)
  ReservationMailer.stubs(:notify_guest_without_confirmation).returns(mailer_stub)
  ReservationMailer.stubs(:notify_host_of_confirmation).returns(mailer_stub)
  ReservationMailer.stubs(:notify_guest_of_confirmation).returns(mailer_stub)
  ReservationMailer.stubs(:notify_guest_of_rejection).returns(mailer_stub)
  ReservationMailer.stubs(:notify_host_of_cancellation).returns(mailer_stub)
  UserMailer.stubs(:email_verification).returns(mailer_stub)
end

Before('@listing_emails') do
  PrepareEmail.for('listing_mailer/share')
  prepare_layout_mailer
end

Before('@login_emails') do
  PrepareEmail.for('user_mailer/email_verification')
  prepare_layout_mailer
end

Before('@inquiry_emails') do
  PrepareEmail.for('inquiry_mailer/inquiring_user_notification')
  PrepareEmail.for('inquiry_mailer/listing_creator_notification')
  prepare_layout_mailer
end

Before('@reservation_emails') do
  [
    'notify_guest_of_cancellation',
    'notify_guest_of_confirmation',
    'notify_guest_of_expiration',
    'notify_guest_of_rejection',
    'notify_guest_with_confirmation',
    'notify_host_of_cancellation',
    'notify_host_of_confirmation',
    'notify_host_of_expiration',
    'notify_host_with_confirmation',
    'notify_host_without_confirmation'
  ].each do |template|
    PrepareEmail.for("reservation_mailer/#{template}")
  end
  prepare_layout_mailer
end

def prepare_layout_mailer
  PrepareEmail.for('layouts/mailer')
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
