class CustomAttributeDrop < BaseDrop
  # @return [CustomAttributes::CustomAttribute]
  attr_reader :custom_attribute

  # @!method name
  #   Custom attribute name
  #   @return (see CustomAttributes::CustomAttribute#name)
  # @!method label
  #   Custom attribute label
  #   @return (see CustomAttributes::CustomAttribute#label)
  # @!method label_key
  #   Translation key for label
  #   @return [String]
  # @!method valid_values
  #   Valid values for the custom attribute
  #   @return (see CustomAttributes::CustomAttribute#valid_values)
  delegate :name, :label, :label_key, :valid_values, to: :custom_attribute

  def initialize(custom_attribute)
    @custom_attribute = custom_attribute
  end

  def input_html_options
    @custom_attribute.input_html_options.map do |k, v|
      "#{k}=#{v}"
    end.join(' ')
  end

  def wrapper_html_options
    @custom_attribute.wrapper_html_options.map do |k, v|
      "#{k}=#{v}"
    end.join(' ')
  end
end
