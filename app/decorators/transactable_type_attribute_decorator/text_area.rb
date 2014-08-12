class TransactableTypeAttributeDecorator::TextArea < TransactableTypeAttributeDecorator::Input

  def initialize(attribute_decorator)
    @attribute_decorator = attribute_decorator
  end

  def options
    {
      placeholder: @attribute_decorator.placeholder,
      as: :text
    }
  end

end
