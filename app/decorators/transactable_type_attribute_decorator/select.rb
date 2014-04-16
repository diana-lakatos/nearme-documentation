class TransactableTypeAttributeDecorator::Select

  def initialize(attribute_decorator)
    @attribute_decorator = attribute_decorator
  end

  def options
    {
      as: :select,
      collection: @attribute_decorator.valid_values,
      prompt: @attribute_decorator.prompt.blank? ? nil : @attribute_decorator.prompt
    }
  end

end
