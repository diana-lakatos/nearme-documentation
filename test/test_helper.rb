ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/autorun'
require 'turn'

Turn.config.format = :dotted

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

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
    request.env['Authorization'] = @user.authentication_token;
  end

end
