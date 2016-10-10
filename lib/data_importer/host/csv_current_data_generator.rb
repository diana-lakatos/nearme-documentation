require 'csv'

class DataImporter::Host::CsvCurrentDataGenerator < DataImporter::File
  def initialize(user, transactable_type)
    @transactable_type = transactable_type
    @user = user
    @company = @user.companies.first
    @csv_fields_builder = TransactableType::CsvFieldsBuilder.new(transactable_type)
  end

  def generate_csv
    CSV.generate do |csv|
      csv << @csv_fields_builder.get_all_labels
      get_data(csv)
    end
  end

  def get_data(csv)
    @company.locations.order('instance_id, external_id').find_each do |location|
      if location.listings.any?
        location.listings.for_transactable_type_id(@transactable_type.id).order('instance_id, external_id').find_each do |listing|
          if listing.photos.any?
            listing.photos.find_each do |photo|
              csv << get_data_row(location, location.location_address, listing, photo)
            end
          else
            csv << get_data_row(location, location.location_address, listing)
          end
        end
      else
        csv << get_data_row(location, location.location_address)
      end
    end
  end

  private

  def get_data_row(location = nil, address = nil, transactable = nil, photo = nil)
    @csv_fields_builder.object_field_pairs.inject([]) do |data_row, object_field_pair|
      if @csv_fields_builder.valid_object_field_pair?(object_field_pair)
        object = object_field_pair.keys.first
        field = object_field_pair[object]
        model = case object
                when 'location'
                  location
                when 'address'
                  address
                when 'transactable'
                  transactable
                when 'photo'
                  photo
                end
        data_row << begin
          if object == 'transactable' && model.present? && !model.respond_to?(field)
            if field == 'listing_categories'
              model.categories.map(&:permalink).join(',')
            elsif field =~ /_price_cents/
              if model.action_type
                price = model.action_type.pricings.find { |p| p.units_to_s == field.match(/for_(.*)_price_cents/)[1] }
                price.is_free_booking? ? 'Free' : price.price_cents if price
              end
            else
              model.try(:properties).try(:send, field)
            end
          else
            model.try(:send, field)
          end
        end
      end
      data_row
    end
  end
end
