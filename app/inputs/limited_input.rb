# frozen_string_literal: true
module LimitedInput
  def prepare_limiter
    return '' if maxlength.to_i.zero?
    add_extra_input_html_options!
    template.content_tag(:p, I18n.t('form.characters_left', count: 0), data: data_attributes, class: 'help-block limiter')
  end

  protected

  def maxlength
    @maxlength ||= object.is_a?(BaseForm) ? reform_maxlength : old_maxlength
  end

  def old_maxlength
    object.try(:validation_for, attribute_name).try(:max_length_rule) || options[:limit] || column.limit
  end

  def reform_maxlength
    object.class
          .validators_on(attribute_name)
          .detect { |v| v.is_a?(ActiveModel::Validations::LengthValidator) }
         &.options
         &.fetch(:maximum, nil)
  end

  def add_extra_input_html_options!
    input_html_options[:class] << 'limited'
    input_html_options[:data] ||= {}
    input_html_options[:maxlength] = maxlength
    input_html_options[:data][:'counter-limit'] = maxlength
  end

  def data_attributes
    normalized_object_name = object_name.to_s.tr('[', '_').delete(']') # attribute[value] to attribute_value
    {
      'counter-for': "#{normalized_object_name}_#{attribute_name}",
      'label-one': t('form.characters_left.one'),
      'label-few': t('form.characters_left.few'),
      'label-zero': t('form.characters_left.zero')
    }
  end
end
