# frozen_string_literal: true
require 'liquid_view/html_partial_wrapper'

class LiquidView
  class PartialCommentWrapper
    def initialize(options)
      @options = options
      @html_partial_wrapper = HtmlPartialWrapper.new(path: path, locals: locals)
    end

    def wrap(text)
      @html_partial_wrapper.wrap(text)
    end

    protected

    def locals
      @options[:locals]&.keys || []
    end

    def path
      @options[:partial]
    end
  end
end
