class SwitchInput < SimpleForm::Inputs::BooleanInput
  def input(wrapper_options = nil)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    merged_input_options[:class] ||= []
    merged_input_options[:class].push('onoffswitch-checkbox')

    template.content_tag(:div, :class => 'onoffswitch') do
      build_check_box(unchecked_value, merged_input_options) +
      @builder.label(label_target, { class: 'onoffswitch-label'}) do
        template.content_tag(:div, '', { class: 'onoffswitch-inner', data: { :"label-off" => 'Off', :"label-on" => 'On' } }) + template.content_tag(:span, '', {class: 'onoffswitch-switch'})
      end
    end
  end
end
