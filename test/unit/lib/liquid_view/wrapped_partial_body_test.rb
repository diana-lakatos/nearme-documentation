# frozen_string_literal: true
require 'test_helper'

class LiquidViewWrappedPartialBodyTest < ActiveSupport::TestCase
  class DummyDebugInformation
    def wrap(text)
      "wrapped #{text}"
    end
  end

  should 'wrap text with comment' do
    locals = { variable1: 'value1', variable2: 'value2' }
    partial = 'my/path'
    wrapped_partial_body = LiquidView::WrappedPartialBody.new(locals: locals, partial: partial)
    wrapped_partial_body.stubs(:debug_information).returns(DummyDebugInformation.new)

    assert_equal 'wrapped this is text',
                 wrapped_partial_body.wrapped_body('this is text')
  end
end
