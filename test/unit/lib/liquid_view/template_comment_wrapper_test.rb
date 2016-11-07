# frozen_string_literal: true
require 'test_helper'

class LiquidViewCommentWrapperTest < ActiveSupport::TestCase
  class DummyHtmlWrapper
    def wrap(text)
      "wrapped #{text}"
    end
  end
  should 'wrap text with comment' do
    variables = %w(variable1 variable2)
    paths = %w(path/one alternative_path/second)
    LiquidView::VariablesExtractor.stubs(:variables).returns(variables)
    LiquidView::PathsExtractor.stubs(:paths).returns(paths)
    LiquidView::HtmlTemplateWrapper.stubs(:new).with(variables: variables, paths: paths).returns(DummyHtmlWrapper.new)

    assert_equal 'wrapped this is text',
                 LiquidView::TemplateCommentWrapper.new(mock, mock).wrap('this is text')
  end
end
