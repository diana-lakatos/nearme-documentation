# frozen_string_literal: true
require 'liquid_view/html_template_wrapper'
require 'liquid_view/variables_extractor'
require 'liquid_view/paths_extractor'
class LiquidView
  class TemplateCommentWrapper
    def initialize(context, options)
      @context = context
      @options = options
      @html_wrapper = LiquidView::HtmlTemplateWrapper.new(variables: variables, paths: paths)
    end

    def wrap(text)
      @html_wrapper.wrap(text)
    end

    protected

    def variables
      LiquidView::VariablesExtractor.variables(@context)
    end

    def paths
      LiquidView::PathsExtractor.paths(@options)
    end
  end
end
