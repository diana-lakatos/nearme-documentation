class Listing::SearchFetcher
  extend ::NewRelic::Agent::MethodTracer

  TOP_CITIES = ['san francisco', 'london', 'new york', 'los angeles', 'chicago']

  def initialize(filters = {})
    if filters.fetch(:transactable_type_id, nil).blank?
      raise NotImplementedError.new('transactable_type_id filter is mandatory')
    end
    @midpoint = filters[:midpoint]
    @radius = filters[:radius]
    @filters = filters
  end

  def listings
    @listings = filtered_listings.joins(:location).merge(filtered_locations)
  end

  def locations
    @locations = filtered_locations.includes(:listings).merge(filtered_listings)
  end

  private

  def filtered_locations
    @locations_scope = Location.all
    @locations_scope = @locations_scope.includes(:location_address).near(@midpoint, @radius, :order => "#{Address.order_by_distance_sql(@midpoint[0], @midpoint[1])} ASC") if @midpoint.present? && @radius.present?
    @locations_scope = @locations_scope.filtered_by_location_types_ids(@filters[:location_types_ids]) if @filters[:location_types_ids]
    @locations_scope = @locations_scope.filtered_by_industries_ids(@filters[:industries_ids]) if @filters[:industries_ids]
    @locations_scope = @locations_scope.order(Location.build_order(@filters.except(:price))) if Location.can_order_by?(@filters.except(:price))
    @locations_scope
  end

  def filtered_listings
    @listings_scope = Transactable.searchable.where(transactable_type_id: @filters[:transactable_type_id])
    @listings_scope = @listings_scope.filtered_by_price_types(@filters[:listing_pricing] & (Transactable::PRICE_TYPES + [:free]).map(&:to_s)) if @filters[:listing_pricing]

    (@filters[:custom_attributes] || {}).each do |field_name, values|
      next if values.blank? || values.all?(&:blank?)
      @listings_scope = @listings_scope.filtered_by_custom_attribute(field_name, values)
    end

    if @filters[:category_ids].present?
      if PlatformContext.current.instance.category_search_type == "AND"
        @listings_scope = @listings_scope.
          joins(:categories_transactables).
          where(categories_transactables: {category_id: @filters[:category_ids]}).
          group('transactables.id').having("count(category_id) >= #{@filters[:category_ids].size}")
      else
        @listings_scope = @listings_scope.includes(:categories).where(categories: {id: @filters[:category_ids]})
      end
    end
    
    @listings_scope = @listings_scope.where('transactables.fixed_price_cents >= ? AND transactables.fixed_price_cents <= ?', @filters[:price][:min].to_i * 100, @filters[:price][:max].to_i * 100) if @filters[:price] && !@filters[:price][:max].to_i.zero?
    
    # Date pickers
    if availability_filter?
      if relative_availability?
        @listings_scope = @listings_scope.not_booked_relative(@filters[:date_range].first, @filters[:date_range].last)
        @listings_scope = @listings_scope.only_opened_on_at_least_one_of(date_range_to_days)
      else
        @listings_scope = @listings_scope.not_booked_absolute(@filters[:date_range].first, @filters[:date_range].last)
        @listings_scope = @listings_scope.only_opened_on_all_of(date_range_to_days)
      end
    end

    @listings_scope = Transactable.where(id: @listings_scope.pluck(:id))
    @listings_scope = @listings_scope.order(Transactable.build_order(@filters)) if Transactable.can_order_by?(@filters)
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
    @filters[:availability] && @filters[:availability][:dates][:start].present? && @filters[:availability][:dates][:end].present?
  end

  def relative_availability?
    @relative ||= PlatformContext.current.instance.date_pickers_relative_mode?
  end
end
