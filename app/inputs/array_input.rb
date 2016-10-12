class ArrayInput < SimpleForm::Inputs::StringInput
  def input(_wrapper_options)
    input_html_options[:type] ||= input_type
    @builder.text_field(nil, input_html_options.merge(name: "#{object_name}[#{attribute_name}][]")).html_safe
  end

  def input_type
    :text
  end
end
