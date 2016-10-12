class PriceInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options)
    input_html_options[:value] ||= template.number_with_precision(@builder.object.send(attribute_name), precision: 2)
    template.content_tag :div, class: 'input-group' do
      template.content_tag(:span, input_html_options[:currency], class: 'input-group-addon') +
        super
    end
  end
end
