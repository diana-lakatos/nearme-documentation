require 'singleton'

class InstanceViewResolver < DbViewResolver
  include Singleton

  def find_templates(name, prefix, partial, details)
    conditions = {
      :path => normalize_path(name, prefix),
      :locale => normalize_array(details[:locale]).first,
      :format => normalize_array(details[:formats]).first,
      :handler => normalize_array(details[:handlers]),
      :partial => partial || false
    }
    scope = ::InstanceView.for_instance_id(details[:instance_id])
    scope = if details[:transactable_type_id].present?
      scope.for_transactable_type_id(details[:transactable_type_id]).order('instance_id, transactable_type_id')
    else
      scope.for_nil_transactable_type.order('instance_id')
    end
    scope = scope.where(conditions)
    scope.map do |record|
      initialize_template(record, record.format)
    end
  end

end

