# frozen_string_literal: true
class RadioInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options)
    "#{
      @builder.radio_button(attribute_name,
        options[:input_html][:value],
        options[:input_html]
      )
    }".html_safe
  end
end
