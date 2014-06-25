class TransactableTypeAttributeDecorator::Select < TransactableTypeAttributeDecorator::Base

  def options
    {
      collection: @attribute_decorator.valid_values_translated,
    }
  end

end
