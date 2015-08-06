class ServiceTypeSelectTag < TransactableTypeSelectTag
  def klass
    ServiceType
  end

  def classes
    %w(service-type-select-tag) + super
  end
end

Liquid::Template.register_tag('service_type_select', ServiceTypeSelectTag)
