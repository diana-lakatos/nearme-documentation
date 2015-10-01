class CustomFieldsBuilder

  def initialize(form_component)
    @form_type = form_component.form_type
    @form_component = form_component
    @form_componentable = form_component.form_componentable
  end

  def all_valid_object_field_pairs
    case @form_type
    when FormComponent::SPACE_WIZARD
      if @form_componentable.instance_of?(ServiceType)
        to_object_field_notation(user_fields, 'user') +
          to_object_field_notation(company_fields, 'company') +
          to_object_field_notation(location_fields, 'location') +
          to_object_field_notation(transactable_fields, 'transactable')
      elsif @form_componentable.instance_of?(Spree::ProductType)
        to_object_field_notation(user_fields, 'user') +
          to_object_field_notation(company_fields, 'company') +
          to_object_field_notation(product_fields, 'product')
      elsif @form_componentable.instance_of?(ProjectType)
        to_object_field_notation(user_fields, 'user') +
          to_object_field_notation(project_fields, 'project')
      else
        raise NotImplementedError.new("Unknown form type: #{@form_type}")
      end
    when FormComponent::PRODUCT_ATTRIBUTES
      to_object_field_notation(product_fields, 'product')
    when FormComponent::PROJECT_ATTRIBUTES
      to_object_field_notation(project_fields, 'project')
    when FormComponent::TRANSACTABLE_ATTRIBUTES
      to_object_field_notation(dashboard_transactable_fields, 'transactable')
    when FormComponent::INSTANCE_PROFILE_TYPES
      to_object_field_notation(user_fields, 'user')
    else
      raise NotImplementedError
    end
  end

  def object_field_pairs
    @object_field_pairs ||= build_object_field_pairs
  end

  def get_label(object_field_pair)
    object = object_field_pair.keys.first
    field = object_field_pair[object]
    "#{object.humanize} - #{field.to_s.humanize}"
  end

  def valid_object_field_pair?(object_field_pair)
    object = object_field_pair.keys.first
    field = object_field_pair[object]
    all_valid_fields_for_object(object).include?(field)
  end

  protected

  def build_object_field_pairs
    @form_component.form_fields.try(:any?) ? @form_component.form_fields : all_valid_object_field_pairs
  end

  def all_valid_fields_for_object(object)
    case @form_type
    when FormComponent::SPACE_WIZARD
      case object
      when 'user'
        user_fields
      when 'company'
        company_fields
      when 'location'
        location_fields
      when 'transactable'
        transactable_fields
      when 'product'
        product_fields
      else
        raise NotImplementedError.new("Unknown object for which field #{field} was defined: #{object}. Valid objects: location, address, transactable, product")
      end
    when FormComponent::PRODUCT_ATTRIBUTES
      case object
      when 'product'
        product_fields
      else
        raise NotImplementedError.new("Unknown object for which field #{field} was defined: #{object}. Valid objects: location, address, product, photo")
      end
    end
  end

  def form_attributes
    @form_attributes = FormAttributes.new
  end

  def user_fields
    @user_fields = form_attributes.user.map(&:to_s)
  end

  def company_fields
    @company_fields = form_attributes.company.map(&:to_s)
  end

  def location_fields
    @location_fields = form_attributes.location.map(&:to_s)
  end

  def transactable_fields
    @transactable_fields ||= form_attributes.transactable(@form_componentable).map(&:to_s)
  end

  def dashboard_transactable_fields
    @transactable_fields ||= form_attributes.dashboard_transactable(@form_componentable).map(&:to_s)
  end

  def product_fields
    @product_fields ||= form_attributes.product(@form_componentable).map(&:to_s)
  end

  def project_fields
    @project_fields ||= form_attributes.project(@form_componentable).map(&:to_s)
  end

  def to_object_field_notation(array, object)
    array.map { |field, label| { "#{object}" => field } }
  end

end
