class TransactableTypeAttributeDecorator::Select

  def initialize(attribute_decorator)
    @attribute_decorator = attribute_decorator
  end

  def options
    {
      as: :select,
      collection: @attribute_decorator.valid_values,
      input_html: { prompt: @attribute_decorator.prompt }
    }
  end

end
