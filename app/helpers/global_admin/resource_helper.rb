module GlobalAdmin::ResourceHelper
  def admin_resource_class_title
    resource_class.name.underscore.humanize
  end

  def admin_resource_name(resource)
    [:name, :title].each do |method|
      return resource.send(method) if resource.respond_to?(method)
    end

    "#{resource.class.name}##{resource.id}"
  end

  def admin_resource_form_attributes(resource)
    attrs = resource.attributes.keys.map(&:to_s)
    attrs -= %w(id created_at updated_at deleted_at)
    attrs
  end

  def admin_resource_field_options(_resource, _field)
    {}
  end
end
