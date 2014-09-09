class TransactableTypeAttributeDecorator::Input < TransactableTypeAttributeDecorator::Base

  def options
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
