# frozen_string_literal: true
class ErrorsSummary
  def initialize(form)
    @form = form
  end

  def summary(separator: "\n")
    @form.errors.each_with_object({}) do |(attr_name, msg), hash|
      splitted = attr_name.to_s.split('.')
      hash[attr_name] = message(@form, splitted, msg)
    end.values.join(separator)
  end

  protected

  def message(form, name_components, msg)
    if name_components.length == 1
      "#{form.class.human_attribute_name(name_components.first)} #{msg}"
    else
      message(Array(form.send(name_components.shift)).first, name_components, msg)
    end
  end
end
