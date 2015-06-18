require 'singleton'

class InstanceViewResolver < DbViewResolver
  include Singleton

  def find_templates(name, prefix, partial, details)
    views = _find_templates name, prefix, partial, details

    # Fallback to English
    if views.count < 1 && normalize_array(details[:locale]).first != 'en'
      details[:locale] = [:en]
      views = _find_templates name, prefix, partial, details
    end

    views
  end

  def get_body(name, prefix, partial, details)
    get_templates(name, prefix, partial, details).first.try(:body)
  end

  private

  def _find_templates(name, prefix, partial, details)
    get_templates(name, prefix, partial, details).map do |record|
      initialize_template(record, record.format)
    end
  end

  def get_templates(name, prefix, partial, details)
    conditions = {
      :path => normalize_path(name, prefix),
      :locale => normalize_array(details[:locale]).first,
      :format => normalize_array(details[:formats]),
      :handler => normalize_array(details[:handlers]),
      :partial => partial || false
    }

    scope = ::InstanceView.for_instance_id(details[:instance_id])
    scope = if details[:transactable_type_id].present?
              scope.for_transactable_type_id(details[:transactable_type_id]).order('instance_id, transactable_type_id')
            else
              scope.for_nil_transactable_type.order('instance_id')
            end

    scope.where(conditions)
  end
end

