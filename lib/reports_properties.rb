module ReportsProperties

  def get_hstore_columns_for_transactable_type(transactable_type_id = nil)
    options = {
      target_type: 'ServiceType',
    }

    options[:target_id] = transactable_type_id if transactable_type_id.present?

    CustomAttributes::CustomAttribute.with_deleted.where(options).uniq.pluck(:name).sort
  end

  def get_hstore_columns_for_product_type(product_type_id = nil)
    options = {
      target_type: 'Spree::ProductType',
    }

    options[:target_id] = product_type_id if product_type_id.present?

    CustomAttributes::CustomAttribute.with_deleted.where(options).uniq.pluck(:name).sort
  end

  def export_data_to_csv_for_transactables(transactables, transactable_type)
    properties_columns = get_hstore_columns_for_transactable_type(transactable_type.try(:id))
    csv = export_data_to_csv(transactables, Transactable.attribute_names, properties_columns, :properties)

    csv
  end

  def export_data_to_csv_for_products(products, product_type)
    properties_columns = get_hstore_columns_for_product_type(product_type.try(:id))

    export_data_to_csv(products, Spree::Product.attribute_names, properties_columns, :extra_properties)
  end

  def export_data_to_csv(items, attribute_names, properties_columns, properties_column_name)
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
