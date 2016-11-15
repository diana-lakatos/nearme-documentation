# frozen_string_literal: true
ENV['RAILS_ENV'] ||= 'test'

require 'minitest/autorun'
require 'minitest/reporters'
require 'active_support'

reporter_options = { color: true, slow_count: 5 }
Minitest::Reporters.use!(Minitest::Reporters::DefaultReporter.new(reporter_options), ENV, Minitest.backtrace_filter)
