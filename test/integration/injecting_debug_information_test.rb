# frozen_string_literal: true
require 'test_helper'

class InjectingDebugInformationTest < ActionDispatch::IntegrationTest
  setup do
    @template_debug_information = '*** Debug information for Admin ***'
    @partial_debug_information = '<!-- layouts/hero -->'
    LiquidView::WrappedTemplateBody.any_instance.stubs(:wrap).returns(@debug_information)
  end

  should 'display comment information if guard returns true' do
    LiquidView::CommentWrapperGuard.stubs(:authorized?).returns(true)
    get '/'
    assert_select @template_debug_information, true
    assert_select @partial_debug_information, true
  end

  should 'not display comment information if guard returns false' do
    LiquidView::CommentWrapperGuard.stubs(:authorized?).returns(false)
    get '/'
    assert_select @template_debug_information, false
    assert_select @partial_debug_information, false
  end
end
