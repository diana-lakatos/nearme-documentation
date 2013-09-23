require 'test_helper'

class StackTraceParserTest < ActiveSupport::TestCase

  context 'parsing' do

    setup do
      @stack_trace_parser = StackTraceParser.new("/Users/mkk/projects/rails/desksnearme/app/models/analytics/user_events.rb:14:in `logged_in'")
    end

    should "return humanized file name" do
      assert_equal "User events", @stack_trace_parser.humanized_file_name
    end

    should "return humanized method name" do
      assert_equal "Logged in", @stack_trace_parser.humanized_method_name
    end
  end
end
