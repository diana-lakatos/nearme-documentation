# frozen_string_literal: true
require 'test_helper'

class LiquidViewWrappedTemplateBodyTest < ActiveSupport::TestCase
  class DummyDebugInformation
    def wrap(text)
      "wrapped #{text}"
    end
  end
  should 'wrap text with comment' do
    variables = %w(variable1 variable2)
    paths = %w(path/one alternative_path/second)
    LiquidView::TemplateVariable.stubs(:all).returns(variables)
    LiquidView::TemplatePath.stubs(:all).returns(paths)

    wrapped_partial_body = LiquidView::WrappedTemplateBody.new(mock, mock)
    wrapped_partial_body.stubs(:debug_information).returns(DummyDebugInformation.new)

    assert_equal 'wrapped this is text',
                 wrapped_partial_body.wrapped_body('this is text')
  end
end
