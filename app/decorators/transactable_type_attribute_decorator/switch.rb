class TransactableTypeAttributeDecorator::Switch

  def initialize(attribute_decorator)
    @attribute_decorator = attribute_decorator
  end

  def options
    {}
  end
end
