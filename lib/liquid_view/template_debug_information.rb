# frozen_string_literal: true
class LiquidView
  class TemplateDebugInformation
    def initialize(variables:, paths:)
      @variables = variables
      @paths = paths
    end

    def wrap(text)
      header + text + footer
    end

    protected

    def header
      %{
<!--
*** Debug information for Admin ***

This view responds to the following paths (sorted by priority):

#{print_paths}

Following variables are available:

#{print_variables}
-->
      }.html_safe
    end

    def footer
      ''
    end

    def print_variables
      @variables.map { |v| "\t#{v}" }.join("\n")
    end

    def print_paths
      @paths.map { |p| "\t#{p}" }.join("\n")
    end
  end
end
