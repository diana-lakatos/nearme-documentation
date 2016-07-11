class TransactableType::CsvFieldsBuilder

  def initialize(importable, additional_models = [])
    @importable = importable
    @models = if import_model == :transactable
                models = [:address, import_model, :photo]
                models.unshift(:location) unless @importable.skip_location?
                additional_models + models
              else
                additional_models + [import_model, :'spree/variant', :'spree/shipping_category', :'spree/image']
              end
  end

  def all_valid_object_field_pairs
    @models.map { |model| to_object_field_notation(model) }.flatten
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
    csv_fields_for_object(object).fetch(field, nil)
  end

  def valid_object_field_pair?(object_field_pair)
    object = object_field_pair.keys.first
    field = object_field_pair[object]
    csv_fields_for_object(object).include?(field)
  end

  protected

  def build_object_field_pairs
    @importable.custom_csv_fields.any? ? @importable.custom_csv_fields : all_valid_object_field_pairs
  end

  def csv_fields_for_object(object)
    klass = object.to_s.classify.constantize
    case object
      when 'company'
        @company_fields ||= (klass == import_class ? klass.csv_fields(@importable) : klass.csv_fields).with_indifferent_access
      when 'location'
        @location_fields ||= (klass == import_class ? klass.csv_fields(@importable) : klass.csv_fields).with_indifferent_access
      when 'address'
        @address_fields ||= (klass == import_class ? klass.csv_fields(@importable) : klass.csv_fields).with_indifferent_access
      when 'transactable'
        @transactable_fields ||= (klass == import_class ? klass.csv_fields(@importable) : klass.csv_fields).with_indifferent_access
      when 'photo'
        @photo_fields ||= (klass == import_class ? klass.csv_fields(@importable) : klass.csv_fields).with_indifferent_access
      else
        (klass == import_class ? klass.csv_fields(@importable) : klass.csv_fields).with_indifferent_access
      end
  end

  def to_object_field_notation(model)
    csv_fields_for_object(model).map { |field, _| { model.to_s => field.to_s } }
  end

  def import_class
    @import_class ||= import_model.to_s.classify.constantize
  end

  def import_model
    @import_model ||= @importable.class.name.sub('ServiceType', 'TransactableType').sub('Type', '').underscore.to_sym
  end

end
