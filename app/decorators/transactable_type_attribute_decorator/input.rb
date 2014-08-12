class TransactableTypeAttributeDecorator::Input < TransactableTypeAttributeDecorator::Base

  def options
    default_options.deep_merge(custom_as)
  end

  def default_options
    {
      placeholder: @attribute_decorator.placeholder
    }
  end

  def custom_as
    return {} unless limit
    if limit.to_f <= 50
      { as: :limited_string }
    else
      { as: :limited_text }
    end.merge({
      limit: limit,
      input_html: { :maxlength => limit }
    })
  end

  def limit
    @attribute_decorator.validation_rules["length"]["maximum"]
  rescue
    nil
  end
end
