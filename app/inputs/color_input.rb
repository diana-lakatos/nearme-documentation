class ColorInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options)
    input_html_options[:type] = 'color'
    super
  end
end
