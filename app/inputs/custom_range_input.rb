class CustomRangeInput < SimpleForm::Inputs::RangeInput
  def input(wrapper_options = nil)
    input_html_options[:value] = model_value if model_value.present?

    output_tag(class: 'range-output-left') +
      super +
      output_tag(class: 'range-output-right')
  end

  private

  def output_tag(options = {})
    html_options = {
      for: attr_id
    }.merge!(options)

    content_tag(:output, model_value, html_options)
  end

  def attr_id
    "#{object_name + attribute_name.to_s}".gsub(/[\[\]]/, '_')
  end

  def model_value
    @model_value ||= object.send(attribute_name)
  end
end
