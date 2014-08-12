class TransactableTypeAttributeDecorator::RadioButto < TransactableTypeAttributeDecorator::Base

  def options
    {
      as: :radio_buttons,
      collection: @attribute_decorator.valid_values,
    }
  end

end
