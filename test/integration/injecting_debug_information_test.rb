# frozen_string_literal: true
require 'test_helper'

class InjectingDebugInformationTest < ActionDispatch::IntegrationTest
  setup do
    @debug_information = '<h1>debug_information_included</h1>'
    LiquidView::TemplateCommentWrapper.any_instance.stubs(:wrap).returns(@debug_information)
  end

  should 'display comment information if guard returns true' do
    LiquidView::CommentWrapperGuard.stubs(:authorized?).returns(true)
    get '/'
    assert_select @debug_information, true
  end

  should 'not display comment information if guard returns false' do
    LiquidView::CommentWrapperGuard.stubs(:authorized?).returns(false)
    get '/'
    assert_select @debug_information, false
  end
end
