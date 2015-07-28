class LimitedStringInput < SimpleForm::Inputs::StringInput
  include LimitedInput

  def input(wrapper_options)
    limiter = prepare_limiter
    "#{@builder.text_field(attribute_name, input_html_options)}#{limiter}".html_safe
  end
end
