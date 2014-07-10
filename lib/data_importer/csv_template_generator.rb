require 'csv'

class DataImporter::CsvTemplateGenerator < DataImporter::File

  def initialize(transactable_type)
    @transactable_type = transactable_type
  end

  def generate_template(with_sample_row = false)
    CSV.generate do |csv|
      csv << required_fields
      csv << sample_row if with_sample_row
    end
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
    user_fields.values + company_fields.values + location_fields.values + address_fields.values + transactable_fields.values + photo_fields.values
  end

  def user_fields
    User.csv_fields
  end

  def company_fields
    Company.csv_fields
  end

  def location_fields
    Location.csv_fields
  end

  def address_fields
    Address.csv_fields
  end

  def transactable_fields
    Transactable.csv_fields(@transactable_type)
  end

  def photo_fields
    Photo.csv_fields
  end

end

