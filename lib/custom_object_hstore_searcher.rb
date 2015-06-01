class CustomObjectHstoreSearcher

  def initialize(master_object, initial_scope)
    @master_object = master_object
    @initial_scope = initial_scope
  end

  def transactables(search)
    perform_search = false
    if search && search[:query].present?
      condition, attribute_params = prepare_filtered_hstore_query('properties', search[:query])
      if condition.present?
        perform_search = true
      end
    end

    if perform_search
      @initial_scope.where(condition, *attribute_params)
    else
      @initial_scope
    end
  end

  def products(search)
    perform_search = false
    if search && search[:query].present?
      condition, attribute_params = prepare_filtered_hstore_query('extra_properties', search[:query], 'name', 'description')
      if condition.present?
        perform_search = true
      end
    end

    if perform_search
      @initial_scope.where(condition, *attribute_params)
    else
      @initial_scope
    end
  end

  def prepare_filtered_hstore_query(hstore_column, query, *other_attributes)
    attributes = @master_object.custom_attributes.reject { |ca| !ca.searchable }

    if attributes.length + other_attributes.length > 0
      condition = "CONCAT(" + (([(ActiveRecord::Base.connection.quote_column_name(hstore_column) + "->?")] * attributes.length) + other_attributes.collect { |oa| ActiveRecord::Base.connection.quote_column_name(oa) }).join(", ' ', ") + ") @@ plainto_tsquery(?)"
      return condition, [attributes.collect { |attr| attr.name }, query].flatten
    end

    return false
  end

end

