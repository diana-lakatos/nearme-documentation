class TransactableTypeAttributeDecorator::CheckBoxList < TransactableTypeAttributeDecorator::Base

  def options
    {
      collection: @attribute_decorator.valid_values_translated
    }
  end

end
