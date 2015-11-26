class TimePickerInput < DatePickerInput
  private

  def display_pattern
    I18n.t('timepicker.dformat', default: '%r')
  end

  def picker_pattern
    I18n.t('timepicker.pformat', default: 'HH:mm')
  end

  def date_options
    date_options_base
  end

  def input_button
    template.content_tag :span, class: 'input-group-addon' do
      template.content_tag :span, '', class: 'fa fa-clock-o'
    end
  end
end
