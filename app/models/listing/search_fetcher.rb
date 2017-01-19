class Listing::SearchFetcher
  extend ::NewRelic::Agent::MethodTracer

  TOP_CITIES = ['san francisco', 'london', 'new york', 'los angeles', 'chicago']

  def initialize(filters = {}, transactable_type)
    @transactable_type = transactable_type
    if filters.fetch(:transactable_type_id, nil).blank?
      fail NotImplementedError.new('transactable_type_id filter is mandatory')
    end
    @midpoint = filters[:midpoint]
    @bounding_box = filters[:bounding_box]
    @radius = filters[:radius]
    @filters = filters
  end

  def listings
    @listings = filtered_listings.includes(:company).joins(:location).merge(filtered_locations)
  end

  def locations
    @locations = filtered_locations.includes(:company).includes(:listings).merge(filtered_listings)
  end

  private

  def filtered_locations
    @locations_scope = Location.all
    @locations_scope = @locations_scope.includes(:location_address).near(@midpoint, @radius, order: "#{Address.order_by_distance_sql(@midpoint[0], @midpoint[1])} ASC") if @midpoint.present? && @radius.present? && !@bounding_box.present?
    @locations_scope = @locations_scope.includes(:location_address).bounding_box(@bounding_box, @midpoint) if @bounding_box.present?
    @locations_scope = @locations_scope.filtered_by_location_types_ids(@filters[:location_types_ids]) if @filters[:location_types_ids].present?
    @locations_scope = @locations_scope.order(Location.build_order(@filters.except(:price))) if Location.can_order_by?(@filters.except(:price))
    @locations_scope = @locations_scope.paginate(page: @filters[:page], per_page: @filters[:per_page])
    @locations_scope
  end

  def filtered_listings
    @listings_scope = Transactable.includes(:transactable_type).searchable.where(transactable_type_id: @filters[:transactable_type_id])

    (@filters[:custom_attributes] || {}).each do |field_name, values|
      next if values.blank? || values.all?(&:blank?)
      @listings_scope = @listings_scope.filtered_by_custom_attribute(field_name, values)
    end

    if @filters[:category_ids].present?
      if @transactable_type.category_search_type == 'AND'
        @listings_scope = @listings_scope
                          .joins(:categories_categorizables)
                          .where(categories_categorizables: { category_id: @filters[:category_ids] })
                          .group('transactables.id').having("count(categories_categorizables.category_id) >= #{@filters[:category_ids].size}")
      else
        @listings_scope = @listings_scope.includes(:categories).where(categories: { id: @filters[:category_ids] })
      end
    end

    @listings_scope = @listings_scope.joins('inner join transactable_action_types tat ON tat.id = transactables.action_type_id inner join transactable_pricings tp ON tp.action_id = tat.id').where('tp.price_cents >= ? AND tp.price_cents <= ?', @filters[:price][:min].to_i * 100, @filters[:price][:max].to_i * 100).distinct if @filters[:price] && !@filters[:price][:max].to_i.zero?

    # Date pickers
    if availability_filter?
      if relative_availability?
        @listings_scope = @listings_scope.not_booked_relative(@filters[:date_range].first, @filters[:date_range].last)
        @listings_scope = @listings_scope.only_opened_on_at_least_one_of(date_range_to_days)
      else
        @listings_scope = @listings_scope.not_booked_absolute(@filters[:date_range].first, @filters[:date_range].last)
        @listings_scope = @listings_scope.only_opened_on_all_of(date_range_to_days)
      end
      @listings_scope = @listings_scope.overlaps_schedule_start_date(@filters[:date_range].first)
    end

    @listings_scope = Transactable.where(id: @listings_scope.pluck(:id))
    @listings_scope = @listings_scope.search_by_query([:name, :description, :properties], @filters['query'])
    @listings_scope = @listings_scope.order(Transactable.build_order(@filters)) if Transactable.can_order_by?(@filters)
    @listings_scope = @listings_scope.paginate(page: @filters[:page], per_page: @filters[:per_page])
    @listings_scope
  end

  def date_range_to_days
    @filters[:date_range].inject([]) do |days, date|
      # we need only weekdays, so no point in iterating further
      return days if days.count == 7
      days << date.wday
    end.sort
  end

  def availability_filter?
    @filters[:availability] && @filters[:availability][:dates] && @filters[:availability][:dates][:start].present? && @filters[:availability][:dates][:end].present? && @filters[:date_range].first && @filters[:date_range].last
  end

  def relative_availability?
    @relative ||= @transactable_type.date_pickers_relative_mode?
  end
end
