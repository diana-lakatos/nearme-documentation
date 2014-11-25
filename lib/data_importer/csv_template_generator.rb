require 'csv'

class DataImporter::CsvTemplateGenerator < DataImporter::File

  def initialize(transactable_type)
    @transactable_type = transactable_type
  end

  def generate_template
    CSV.generate do |csv|
      csv << get_content
    end
  end

  def get_content
    required_fields
  end

  def self.value_for_attribute(attr, index)
    case attr
    when :daily_price_cents
      10
    when :weekly_price_cents
      15
    when :monthly_price_cents
      30
    when :hourly_price_cents
      4
    when :enabled
      true
    when :my_attribute
      "my attrs! #{index}"
    when :name
      "my name! #{index}"
    when :confirm_reservations
      true
    when :external_id
      index
    else
      raise "Unknown :#{attr}"
    end
  end

  private

  def required_fields
    @transactable_type.custom_csv_fields.try(:any?) ? custom_fields(@transactable_type.custom_csv_fields) : static_fields
  end

  def custom_fields(fields_array)
    fields_array.map do |object_field_pair|
      object = object_field_pair.keys.first
      field = object_field_pair[object]
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
      end.fetch(field)
    end
  end

  def static_fields
    user_fields.values + company_fields.values + location_fields.values + address_fields.values + transactable_fields.values + photo_fields.values
  end

  def user_fields
    @user_fields ||= User.csv_fields.with_indifferent_access
  end

  def company_fields
    @company_fields ||= Company.csv_fields.with_indifferent_access
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

end

