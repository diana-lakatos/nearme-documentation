class BootstrapSwitchInput < SimpleForm::Inputs::BooleanInput
  def input
    template.content_tag(:div, super, class: "switch", 'data-on-label' => "", 'data-off-label' => "" )
  end

  def nested_boolean_style?
    false
  end
end
