module Admin::ResourceHelper
  def admin_resource_class_title
    resource_class.name.underscore.humanize
  end

  def admin_resource_name(resource)
    if @resource_name_proc
      @resource_name_proc[resource]
    elsif resource.respond_to?(:name)
      resource.name
    elsif resource.respond_to?(:title)
      resource.title
    else
      "#{resource.class.name}##{resource.id}"
    end
  end

  def admin_resource_form_attributes(resource)
    attrs = @form_attributes || resource.attributes.keys.map(&:to_s)
    attrs -= %w(id created_at updated_at deleted_at)
    attrs -= (@form_attributes_skip || [])
    attrs
  end

  def admin_resource_field_options(resource, field)
    # Options defined in controller for field
    options = (@form_attribute_options || {})[field]
    options ||= {}

    case field
    when /country/
      options[:as] = :select
      options[:collection] = Country.all
    end

    case resource.class.columns_hash[field].type
    # Standard options based on field type
    when :boolean
      #options[:wrapper] = :inline_checkbox
    end

    options
  end
end
