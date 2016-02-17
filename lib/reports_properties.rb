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
    csv = export_data_to_csv(transactables, transactables.first.try(:attribute_names), properties_columns)

    csv
  end

  def export_data_to_csv(items, attribute_names = [], properties_columns)
    properties_column_name = items.first.is_a?(Spree::Product) ? :extra_properties : :properties
    csv = CSV.generate do |csv|
      csv << [attribute_names, properties_columns].flatten
      items.each do |record|
        values = record.attributes.values
        properties = record.send(properties_column_name).to_h

        properties_columns.each do |column|
          values << properties[column]
        end

        csv << values
      end
    end

    csv
  end

end
