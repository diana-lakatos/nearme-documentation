class TransactableTypeAttributeDecorator::Select < TransactableTypeAttributeDecorator::Base

  def options
    {
      as: :select,
      collection: @attribute_decorator.valid_values,
      input_html: { prompt: @attribute_decorator.prompt }
    }
  end

end
