# frozen_string_literal: true
class LiquidView
  class PartialDebugInformation
    def initialize(locals:, path:)
      @locals = locals
      @path = path
    end

    def wrap(text)
      header + text + footer
    end

    protected

    def header
      %(
<!-- #{@path}#{print_local_variables} -->
      ).html_safe
    end

    def footer
      %(
<!-- end #{@path}#{print_local_variables} -->
      ).html_safe
    end

    def print_local_variables
      return '' if @locals.blank?
      " | locals: #{@locals.join(', ')}"
    end
  end
end
