# frozen_string_literal: true
class CustomAttributeDrop < BaseDrop
  # @return [CustomAttributeDrop]
  attr_reader :custom_attribute

  # @!method name
  #   @return [String] Custom attribute name
  # @!method label
  #   @return [String] Custom attribute label
  # @!method label_key
  #   @return [String] Translation key for label
  # @!method valid_values
  #   @return [Array<Object>] Valid values for the custom attribute
  delegate :name, :label, :label_key, :valid_values, to: :custom_attribute

  def initialize(custom_attribute)
    @custom_attribute = custom_attribute
  end

  # @return [String] string containing a space-separated list of attributes set for the input
  #   (input html options) in the form e.g. "class=selectpicker name=somevalue"
  # @todo -- document usage with examples
  def input_html_options
    @custom_attribute.input_html_options.map do |k, v|
      "#{k}=#{v}"
    end.join(' ')
  end

  # @return [String] string containing a space-separated list of attributes set for the input
  #   (wrapper html options) in the form e.g. "class=selectpicker name=somevalue"
  # @todo -- document usage with examples
  def wrapper_html_options
    @custom_attribute.wrapper_html_options.map do |k, v|
      "#{k}=#{v}"
    end.join(' ')
  end
end
