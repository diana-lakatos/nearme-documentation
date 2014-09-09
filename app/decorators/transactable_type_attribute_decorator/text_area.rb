class TransactableTypeAttributeDecorator::TextArea < TransactableTypeAttributeDecorator::Input

  def initialize(attribute_decorator)
    @attribute_decorator = attribute_decorator
  end

  def options
    {
      as: :text
    }
  end

end
