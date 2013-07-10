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
    Spork.trap_method(ThinkingSphinx::Context, :prepare)
    Rails.application.railties.all { |r| r.eager_load! }
  end

  require File.expand_path('../../config/environment', __FILE__)

  require 'rails/test_help'
  require 'turn'
  require 'thinking_sphinx/test'
  require 'mocha/setup'
  require 'mocha/integration/test_unit'
  require 'webmock/test_unit'

  Turn.config.format = :dot

  class ActiveSupport::TestCase
    # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
    #
    # Note: You'll currently still have to declare fixtures explicitly in integration tests
    # -- they do not yet inherit this setting

    # Add more helper methods to be used by all tests here...
    include FactoryGirl::Syntax::Methods

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

    def stub_sphinx(listings_to_return)
      ThinkingSphinx::Search.any_instance.stubs(:search).returns(listings_to_return)
    end
    DatabaseCleaner.strategy = :truncation

    def stub_image_url(image_url)
      stub_request(:get, image_url).to_return(:status => 200, :body => File.expand_path("../assets/foobear.jpeg", __FILE__), :headers => {'Content-Type' => 'image/jpeg'})
    end
  end

  ThinkingSphinx::Test.init

end

Spork.each_run do
  # This code will be run each time you run your specs.
  if ENV['DRB']
    require 'simplecov'
  end
  class ActionController::TestCase
    fixtures :all
  end
  class ActiveSupport::TestCase
    fixtures :all
  end
  FactoryGirl.reload
  DatabaseCleaner.clean

end
