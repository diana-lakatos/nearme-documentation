class DataImporter::CsvCurrentDataGenerator < DataImporter::File
  def initialize(transactable_type)
    @transactable_type = transactable_type
    @csv_fields_builder = TransactableType::CsvFieldsBuilder.new(transactable_type, [:company])
  end

  def generate_csv
    CSV.generate do |csv|
      csv << @csv_fields_builder.get_all_labels
      get_data(csv)
    end
  end

  def get_data(csv)
    Company.find_each do |company|
      if company.locations.any?
        company.locations.order('instance_id, external_id').each do |location|
          if location.listings.any?
            location.listings.where(transactable_type: @transactable_type).order('instance_id, external_id').each do |listing|
              if listing.photos.any?
                listing.photos.each do |photo|
                  csv << get_data_row(company, location, location.location_address, listing, photo)
                end
              else
                csv << get_data_row(company, location, location.location_address, listing)
              end
            end
          else
            csv << get_data_row(company, location, location.location_address)
          end
        end
      else
        csv << get_data_row(company)
      end
    end
  end

  private

  def get_data_row(company = nil, location = nil, address = nil, transactable = nil, photo = nil)
    @csv_fields_builder.object_field_pairs.inject([]) do |data_row, object_field_pair|
      if @csv_fields_builder.valid_object_field_pair?(object_field_pair)
        object = object_field_pair.keys.first
        field = object_field_pair[object]
        model = case object
                when 'company'
                  company
                when 'location'
                  location
                when 'address'
                  address
                when 'transactable'
                  transactable
                when 'photo'
                  field = 'original_image_url' if field == 'image_original_url'
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
          elsif object == 'company' && model.present? && field == 'company_industries_list'
            model.industries.map(&:name).join(',')
          else
            model.try(:send, field) if model.respond_to?(field)
          end
        end
      end
      data_row
    end
  end
end
