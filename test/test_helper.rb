require 'rubygems'
require 'spork'
Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  unless ENV['DRB']
    require 'simplecov'
  end
  ENV["RAILS_ENV"] = "test"
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
  FactoryGirl.reload
  DatabaseCleaner.clean

end

# --- Instructions ---
# Sort the contents of this file into a Spork.prefork and a Spork.each_run
# block.
#
# The Spork.prefork block is run only once when the spork server is started.
# You typically want to place most of your (slow) initializer code in here, in
# particular, require'ing any 3rd-party gems that you don't normally modify
# during development.
#
# The Spork.each_run block is run each time you run your specs.  In case you
# need to load files that tend to change during development, require them here.
# With Rails, your application modules are loaded automatically, so sometimes
# this block can remain empty.
#
# Note: You can modify files loaded *from* the Spork.each_run block without
# restarting the spork server.  However, this file itself will not be reloaded,
# so if you change any of the code inside the each_run block, you still need to
# restart the server.  In general, if you have non-trivial code in this file,
# it's advisable to move it into a separate file so you can easily edit it
# without restarting spork.  (For example, with RSpec, you could move
# non-trivial code into a file spec/support/my_helper.rb, making sure that the
# spec/support/* files are require'd from inside the each_run block.)
#
# Any code that is left outside the two blocks will be run during preforking
# *and* during each_run -- that's probably not what you want.
#
# These instructions should self-destruct in 10 seconds.  If they don't, feel
# free to delete them.




