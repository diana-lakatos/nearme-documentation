class TransactableTypeAttributeDecorator::Select < TransactableTypeAttributeDecorator::Base

  def options
    {
      collection: @attribute_decorator.valid_values_translated,
      prompt: I18n.translate("simple_form.prompts.transactable." + @attribute_decorator.name)
    }
  end

end
