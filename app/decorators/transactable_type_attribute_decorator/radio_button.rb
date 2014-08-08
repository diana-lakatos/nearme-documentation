class TransactableTypeAttributeDecorator::RadioButto < TransactableTypeAttributeDecorator::Basen

  def options
    {
      as: :radio_buttons,
      collection: @attribute_decorator.valid_values,
    }
  end

end
