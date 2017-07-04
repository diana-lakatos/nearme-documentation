module MarketplaceReports
  class TransactableReportExporter
    def initialize(collection)
      @collection = collection
    end

    def export_data_to_csv
      attribute_names = @collection.first.try(:attributes).try(:keys)
      properties_columns = get_hstore_columns

      csv = CSV.generate do |csv|
        csv << [attribute_names, 'creator_name', 'creator_email', 'url', 'latitude', 'longitude', 'address', 'street', 'suburb', 'city', 'country', 'state', 'postcode', 'prices', properties_columns].flatten
  
        @collection.find_each do |record|
          record = record.decorate if record.is_a?(Transactable)
          values = record.attributes.values
          properties = record.send(:properties).to_h
  
          values << record.creator&.name
          values << record.creator&.email
          values << record.show_url
          values << record.location&.latitude
          values << record.location&.longitude
          values << record.location&.address
          values << record.location&.location_address&.street
          values << record.location&.location_address&.suburb
          values << record.location&.location_address&.city
          values << record.location&.location_address&.country
          values << record.location&.location_address&.state
          values << record.location&.location_address&.postcode
          values << record.action_type.pricings.inject({}) { |hash, p| hash[p.unit] = p.price_cents; hash }
  
          properties_columns.each do |column|
            values << properties[column]
          end
  
          csv << values
        end
      end
  
      csv
    end

    private

    def get_hstore_columns
      CustomAttributes::CustomAttribute.where(target_type: 'TransactableType').order('name ASC').pluck(:name).uniq
    end
  end
end
