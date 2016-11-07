# frozen_string_literal: true
require 'liquid_view/comment_wrapper_guard'
require 'liquid_view/template_comment_wrapper'
require 'liquid_view/partial_comment_wrapper'

ActionView::TemplateRenderer.class_eval do
  alias_method :old_render, :render

  def render(context, options)
    old_render_result = old_render(context, options)
    return old_render_result unless LiquidView::CommentWrapperGuard.authorized?(context)
    LiquidView::TemplateCommentWrapper.new(context, options).wrap(old_render_result)
  end
end

ActionView::PartialRenderer.class_eval do
  alias_method :old_render, :render

  def render(context, options, block)
    old_render_result = old_render(context, options, block)
    return old_render_result unless LiquidView::CommentWrapperGuard.authorized?(context)
    LiquidView::PartialCommentWrapper.new(options).wrap(old_render_result)
  end
end
