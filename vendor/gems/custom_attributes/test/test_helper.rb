# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require 'shoulda'
require 'mocha/setup'
require 'mocha/mini_test'
require 'minitest/reporters'
require 'factory_girl_rails'
require 'timecop'

Minitest::Reporters.use!

Rails.backtrace_cleaner.remove_silencers!

ActiveSupport::TestCase.class_eval do
  ActiveRecord::Migration.check_pending!

  include FactoryGirl::Syntax::Methods

end

def clear_all_cache!
  ::CustomAttributes::CustomAttribute::CacheDataHolder.clear_all_cache!
end

