# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require 'shoulda'
require 'mocha/setup'
require 'mocha/mini_test'
require 'turn'
require 'factory_girl_rails'
require 'timecop'

Turn.config.format = :dot

Rails.backtrace_cleaner.remove_silencers!

ActiveSupport::TestCase.class_eval do
  ActiveRecord::Migration.check_pending!

  include FactoryGirl::Syntax::Methods

end

