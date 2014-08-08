class TransactableTypeAttributeDecorator::TimeAttr < TransactableTypeAttributeDecorator::Base

  def initialize(attribute_decorator)
    @attribute_decorator = attribute_decorator
  end

  def options
    {
      as: :time
    }
  end

end
