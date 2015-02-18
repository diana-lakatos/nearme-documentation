class Spree::ProductType::CustomFieldsBuilder

  def initialize(form_component)
    @form_component = form_component
    @product_type = form_component.form_componentable
  end

  def all_valid_object_field_pairs
    to_object_field_notation(product_fields, 'product')
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
    when 'product'
      product_fields
    else
      raise NotImplementedError.new("Unknown object for which field #{field} was defined: #{object}. Valid objects: location, address, product, photo")
    end
  end

  def form_attributes
    @form_attributes = FormAttributes.new
  end

  def product_fields
    @product_fields ||= form_attributes.product(@product_type).map(&:to_s)
  end

  def to_object_field_notation(array, object)
    array.map { |field, label| { "#{object}" => field } }
  end

end
