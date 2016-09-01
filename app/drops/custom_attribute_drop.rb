class CustomAttributeDrop < BaseDrop
  attr_reader :custom_attribute

  # name
  #   Custom attribute name
  # label
  #   Custom attribute label
  # label_key
  #   Translation key for label

  delegate :name, :label, :label_key, :valid_values, to: :custom_attribute

  def initialize(custom_attribute)
    @custom_attribute = custom_attribute
  end

end
