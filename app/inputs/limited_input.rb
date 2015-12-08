module LimitedInput
  def prepare_limiter
    maxlength = object.try(:validation_for, attribute_name).try(:max_length_rule) || options[:limit] || column.limit
    return '' if maxlength.to_i == 0
    input_html_options[:class] << 'limited'
    input_html_options[:data] ||= {}
    input_html_options[:maxlength] = maxlength
    input_html_options[:data].merge!(:'counter-limit' => maxlength)
    normalized_object_name = object_name.to_s.gsub('[', '_').gsub(']', '') # attribute[value] to attribute_value
    data = {
      :'counter-for' => "#{normalized_object_name}_#{attribute_name}",
      :'label-one' => t('form.characters_left.one'),
      :'label-few' => t('form.characters_left.few'),
      :'label-zero' => t('form.characters_left.zero')
    }
    template.content_tag(:p, I18n.t('form.characters_left', count: 0), data: data, class: 'help-block limiter')
  end
end
