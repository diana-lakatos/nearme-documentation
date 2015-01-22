class DataImporter::Host::CsvFieldsBuilder

  def initialize(transactable_type)
    @transactable_type = transactable_type
  end

  def all_valid_object_field_pairs
    to_object_field_notation(location_fields, 'location') +
      to_object_field_notation(address_fields, 'address') +
      to_object_field_notation(transactable_fields, 'transactable') +
      to_object_field_notation(photo_fields, 'photo')
  end

  def object_field_pairs
    @object_field_pairs ||= build_object_field_pairs
  end

  def get_all_labels
    object_field_pairs.map do |object_field_pair|
      get_label(object_field_pair).presence || nil
    end.compact
  end

  def get_label(object_field_pair)
    object = object_field_pair.keys.first
    field = object_field_pair[object]
    all_valid_fields_for_object(object).fetch(field, nil)
  end

  def valid_object_field_pair?(object_field_pair)
    object = object_field_pair.keys.first
    field = object_field_pair[object]
    all_valid_fields_for_object(object).include?(field)
  end

  protected

  def build_object_field_pairs
    @transactable_type.custom_csv_fields.try(:any?) ? @transactable_type.custom_csv_fields : all_valid_object_field_pairs
  end

  def all_valid_fields_for_object(object)
    case object
    when 'location'
      location_fields
    when 'address'
      address_fields
    when 'transactable'
      transactable_fields
    when 'photo'
      photo_fields
    else
      raise NotImplementedError.new("Unknown object for which field #{field} was defined: #{object}. Valid objects: location, address, transactable, photo")
    end
  end

  def location_fields
    @location_fields ||= Location.csv_fields.with_indifferent_access
  end

  def address_fields
    @address_fields ||= Address.csv_fields.with_indifferent_access
  end

  def transactable_fields
    @transactable_fields ||= Transactable.csv_fields(@transactable_type).with_indifferent_access
  end

  def photo_fields
    @photo_fields ||= Photo.csv_fields.with_indifferent_access
  end

  def to_object_field_notation(array, object)
    array.map { |field, label| { "#{object}" => field } }
  end

end
