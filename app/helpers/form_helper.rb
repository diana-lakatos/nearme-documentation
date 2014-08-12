module FormHelper

  def required_field(label_text = '')
    ("<abbr title='required'>*</abbr>" + label_text).html_safe
  end

  def draw_attribute_for_form(attribute, form)
    return nil unless attribute.public && attribute.html_tag.present?
    case attribute.html_tag.to_sym
    when :input, :select, :textarea, :radio_buttons, :date, :date_time, :time
      render partial: "custom_attributes/input", locals: { attribute: attribute.decorate, f: form }
    when :check_box
      render partial: "custom_attributes/check_box", locals: { attribute: attribute.decorate, f: form }
    when :switch
      render partial: "custom_attributes/switch", locals: { attribute: attribute.decorate, f: form }
    else
      raise "Unknown: #{attribute.html_tag}"
    end
  end

end
