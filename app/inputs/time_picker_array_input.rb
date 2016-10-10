class TimePickerArrayInput < SimpleForm::Inputs::TextInput
  def input(_wrapper_options)
    Array(object.public_send(attribute_name)).map do |array_el|
      removable_field do
        object.time = array_el
        @builder.input(
          :time,
          as: :time_picker,
          label: false,
          wrapper_html: { class: 'form-control-sm' },
          input_html: input_html_options.merge(name: "#{object_name}[#{attribute_name}][]")
        ) +
          remove_button
      end
    end.join.html_safe + add_time_button
  end

  def add_time_button
    content_tag(
      :div,
      content_tag(:i, I18n.t(:add_time_prefix, scope: [:pricing, :schedule, :specific])) +
      content_tag(:button, t(:add_time, scope: [:pricing, :schedule, :specific]), 'data-input-name': "#{object_name}[#{attribute_name}][]", type: 'button', class: 'btn btn-default', 'data-add-datetime': true),
      class: 'add-entry')
  end

  def removable_field(&_block)
    content_tag(:div, yield, class: 'removable-field')
  end

  def remove_button
    content_tag(:button, I18n.t(:remove_time, scope: [:pricing, :schedule, :specific]), type: 'button', class: 'action--remove', 'data-remove-datetime': true)
  end

  def input_type
    :text
  end
end
