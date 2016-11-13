# frozen_string_literal: true
require 'liquid_view/comment_wrapper_guard'
require 'liquid_view/wrapped_template_body'
require 'liquid_view/wrapped_partial_body'

ActionView::TemplateRenderer.class_eval do
  alias_method :old_render, :render

  def render(context, options)
    old_render_result = old_render(context, options)
    return old_render_result unless LiquidView::CommentWrapperGuard.authorized?(context)
    LiquidView::WrappedTemplateBody.new(context, options).wrapped_body(old_render_result)
  end
end

ActionView::PartialRenderer.class_eval do
  alias_method :old_render, :render

  def render(context, options, block)
    old_render_result = old_render(context, options, block)
    return old_render_result unless LiquidView::CommentWrapperGuard.authorized?(context)
    LiquidView::WrappedPartialBody.new(options).wrapped_body(old_render_result)
  end
end
