class LimitedTextInput < SimpleForm::Inputs::TextInput
  include LimitedInput

  def input(wrapper_options)
    limiter = prepare_limiter
    super + limiter
  end
end
