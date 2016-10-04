# frozen_string_literal: true
require 'test_helper'

class LiquidViewCommentWrapperTest < ActiveSupport::TestCase
  class DummyHtmlWrapper
    def wrap(text)
      "wrapped #{text}"
    end
  end

  should 'wrap text with comment' do
    locals = { variable1: 'value1', variable2: 'value2' }
    partial = 'my/path'
    LiquidView::HtmlPartialWrapper.stubs(:new).with(locals: %i(variable1 variable2), path: partial).returns(DummyHtmlWrapper.new)

    assert_equal 'wrapped this is text',
                 LiquidView::PartialCommentWrapper.new(locals: locals, partial: partial).wrap('this is text')
  end
end
