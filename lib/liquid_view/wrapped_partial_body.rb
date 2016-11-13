# frozen_string_literal: true
require 'liquid_view/partial_debug_information'

class LiquidView
  class WrappedPartialBody
    def initialize(options)
      @options = options
    end

    def wrapped_body(text)
      return text if text.blank?
      debug_information.wrap(text)
    end

    protected

    def debug_information
      LiquidView::PartialDebugInformation.new(path: path, locals: locals)
    end

    def path
      @options[:partial]
    end

    def locals
      @options[:locals]&.keys || []
    end
  end
end
