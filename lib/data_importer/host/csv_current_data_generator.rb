require 'csv'

class DataImporter::Host::CsvCurrentDataGenerator < DataImporter::File

  def initialize(user, transactable_type)
    @transactable_type = transactable_type
    @user = user
    @company = @user.companies.first
  end

  def generate_csv
    CSV.generate do |csv|
      DataImporter::Host::CsvTemplateGenerator.new(@transactable_type).get_content(csv)
      get_data(csv)
    end
  end

  def get_data(csv)
    @company.locations.each do |location|
      data = []
      location_fields.each do |field|
        data << location.send(field)
      end
      address_fields.each do |field|
        data << location.send(field)
      end
      if location.listings.any?
        location.listings.each do |listing|
          listing_data = data + transactable_fields.inject([]) do |arr, field|
            arr << listing.send(field)
          end
          if listing.photos.any?
            listing.photos.each do |photo|
              csv << listing_data + photo_fields.inject([]) do |arr, field|
                arr << photo.send(field)
              end
            end
          else
            csv << listing_data + Array.new(photo_fields.count, nil)
          end
        end
      else
        csv << data + Array.new(transactable_fields.count + photo_fields.count, nil)
      end
    end
  end

  private

  def required_fields
    user_fields.values + company_fields.values + location_fields.values + address_fields.values + transactable_fields.values + photo_fields.values
  end

  def user_fields
    User.xml_attributes
  end

  def company_fields
    Company.xml_attributes
  end

  def location_fields
    Location.xml_attributes
  end

  def address_fields
    Address.csv_fields.keys
  end

  def transactable_fields
    Transactable.xml_attributes(@transactable_type)
  end

  def photo_fields
    Photo.xml_attributes
  end

end

