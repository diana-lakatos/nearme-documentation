module LimitedInput
  def prepare_limiter
    input_html_options[:class] << 'limited'
    input_html_options[:data] ||= {}
    input_html_options[:data].merge!(:'counter-limit' => options[:limit] || column.limit)
    template.content_tag(:p, I18n.t('form.characters_left', count: 0), data: {:'counter-for' => "#{object_name}_#{attribute_name}"}, class: 'help-block limiter')
  end
end
