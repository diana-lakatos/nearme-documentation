require 'codeclimate-test-reporter'
require 'simplecov'

# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.
CodeClimate::TestReporter.start

require 'json_spec/cucumber'
require 'cucumber/rails'

require 'capybara-screenshot/cucumber'
Capybara::Screenshot.autosave_on_failure = true
Capybara::Screenshot.webkit_options = { width: 1824, height: 1368 }

# Keep only the screenshots generated from the last failing test suite
Capybara::Screenshot.prune_strategy = :keep_last_run

require 'rack/utils'
Capybara.app = Rack::ShowExceptions.new(DesksnearMe::Application)

Capybara.default_max_wait_time = 10

# Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
# order to ease the transition to Capybara we set the default here. If you'd
# prefer to use XPath just remove this line and adjust any selectors in your
# steps to use the XPath syntax.
Capybara.javascript_driver = :webkit

# By default, any exception happening in your Rails application will bubble up
# to Cucumber so that your scenario will fail. This is a different from how
# your application behaves in the production environment, where an error page will
# be rendered instead.
#
# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#
ActionController::Base.allow_rescue = false

# Remove/comment out the lines below if your app doesn't have a database.
# For some databases (like MongoDB and CouchDB) you may need to use :truncation instead.
begin
  DatabaseCleaner.strategy = :truncation
rescue NameError
  raise 'You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it.'
end

Before '@photo' do
  PhotoUploader.enable_processing = true
end

Before '~@photo' do
  PhotoUploader.enable_processing = false
end

World(CarrierWave::Test::Matchers)

def last_json
  page.source
end
