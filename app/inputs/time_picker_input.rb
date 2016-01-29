class TimePickerInput < DatePickerInput
  private

  def set_html_options
    input_html_options[:data] ||= {}
    input_html_options[:data][:jsformat] = I18n.t('timepicker.jsformat', default: 'H:i')
    super
  end

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
