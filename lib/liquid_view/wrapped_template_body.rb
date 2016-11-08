# frozen_string_literal: true
require 'liquid_view/template_debug_information'
require 'liquid_view/template_variable'
require 'liquid_view/template_path'
class LiquidView
  class WrappedTemplateBody
    def initialize(context, options)
      @context = context
      @options = options
    end

    def wrapped_body(text)
      debug_information.wrap(text)
    end

    protected

    def debug_information
      LiquidView::TemplateDebugInformation.new(variables: variables, paths: paths)
    end

    def variables
      LiquidView::TemplateVariable.all(@context)
    end

    def paths
      LiquidView::TemplatePath.all(@options)
    end
  end
end
