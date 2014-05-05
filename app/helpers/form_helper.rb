module FormHelper

  def required_field(label_text = '')
    ("<abbr title='required'>*</abbr>" + label_text).html_safe
  end

  def draw_attribute_for_form(attribute, form)
    return nil unless attribute.public
    case attribute.html_tag.to_sym
    when :input, :select
      render partial: "custom_attributes/input", locals: { attribute: attribute.decorate, f: form }
    when :switch
      render partial: "custom_attributes/switch", locals: { attribute: attribute.decorate, f: form }
    else
      raise NotImplementedError.new("Drawing html for #{attribute.to_json} is not implemented.")
    end
  end

end
