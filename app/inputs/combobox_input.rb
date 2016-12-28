# frozen_string_literal: true
class ComboboxInput < SimpleForm::Inputs::CollectionSelectInput
  def input(wrapper_options)
    input_html_options[:multiple] = 'true'
    options[:prompt] = false
    super(wrapper_options)
  end
end
