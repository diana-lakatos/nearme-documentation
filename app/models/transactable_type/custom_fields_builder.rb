class TransactableType::CustomFieldsBuilder

  def initialize(form_component)
    @form_component = form_component
    @transactable_type = form_component.form_componentable
  end

  def all_valid_object_field_pairs
    to_object_field_notation(user_fields, 'user') +
      to_object_field_notation(company_fields, 'company') +
      to_object_field_notation(location_fields, 'location') +
      to_object_field_notation(transactable_fields, 'transactable')
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
    case object
    when 'user'
      user_fields
    when 'company'
      company_fields
    when 'location'
      location_fields
    when 'transactable'
      transactable_fields
    else
      raise NotImplementedError.new("Unknown object for which field #{field} was defined: #{object}. Valid objects: location, address, transactable, photo")
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
    @transactable_fields ||= form_attributes.transactable(@transactable_type).map(&:to_s)
  end

  def to_object_field_notation(array, object)
    array.map { |field, label| { "#{object}" => field } }
  end

end
