# frozen_string_literal: true
class CodeEditorInput < SimpleForm::Inputs::TextInput
  def input(wrapper_options)
    input_html_options[:'data-syntax'] = options[:syntax].presence || 'htmlmixed'
    input_html_options[:rows] = 30
    input_html_options[:cols] = 80
    super
  end
end
