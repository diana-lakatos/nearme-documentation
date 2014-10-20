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

    ::InstanceView.for_instance_id(details[:instance_id]).where(conditions).map do |record|
      initialize_template(record, record.format)
    end
  end

end
