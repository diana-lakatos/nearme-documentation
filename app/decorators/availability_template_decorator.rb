class AvailabilityTemplateDecorator < Draper::Decorator
  delegate_all

  def name_underscored
    name.underscore.tr(' ', '_')
  end

  def translated_name
    if custom?
      I18n.t('simple_form.labels.availability_template.custom')
    else
      I18n.t("simple_form.labels.availability_template.full_name.#{name_underscored}")
    end
  end

  def translated_description
    if custom?
      I18n.t('simple_form.hints.availability_template.description.custom')
    else
      I18n.t("simple_form.hints.availability_template.description.#{name_underscored}")
    end
  end

end
