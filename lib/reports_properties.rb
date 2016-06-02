module ReportsProperties

  def get_hstore_columns(transactables)
    if transactables.first.is_a?(User)
      InstanceProfileType.all.map do |ipt|
        ipt.custom_attributes.with_deleted.pluck(:name)
      end.flatten.uniq.sort
    else
      transactables.map(&:transactable_type).compact.uniq.map do |transactable_type|
        transactable_type.custom_attributes.with_deleted.pluck(:name)
      end.flatten.uniq.sort
    end
  end

  def export_data_to_csv_for(transactables)
    properties_columns = get_hstore_columns(transactables)
    csv = export_data_to_csv(transactables, transactables.first.try(:attributes).try(:keys), properties_columns)

    csv
  end

  def export_data_to_csv(items, attribute_names = [], properties_columns)
    properties_column_name = items.first.is_a?(Spree::Product) ? :extra_properties : :properties

    csv = CSV.generate do |csv|
      if items.first.is_a?(Transactable)
        csv << [attribute_names, 'url', 'latitude', 'longitude', 'address', 'street', 'suburb', 'city', 'country', 'state', 'postcode', properties_columns].flatten
      else
        csv << [attribute_names, properties_columns].flatten
      end

      items.each do |record|
        record = record.decorate if record.is_a?(Transactable)
        values = record.attributes.values
        properties = record.send(properties_column_name).to_h

        if record.is_a?(Transactable)
          values << record.show_url
          values << record.location.latitude
          values << record.location.longitude
          values << record.location.address
          values << record.location.location_address.street
          values << record.location.location_address.suburb
          values << record.location.location_address.city
          values << record.location.location_address.country
          values << record.location.location_address.state
          values << record.location.location_address.postcode
        end

        properties_columns.each do |column|
          values << properties[column]
        end

        csv << values
      end
    end

    csv
  end

end
