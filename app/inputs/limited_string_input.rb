class LimitedStringInput < SimpleForm::Inputs::StringInput
  include LimitedInput

  def input(wrapper_options)
    input_html_options[:type] = 'text'
    limiter = prepare_limiter
    super + limiter
  end
end
