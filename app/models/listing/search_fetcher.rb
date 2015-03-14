class Listing::SearchFetcher
  extend ::NewRelic::Agent::MethodTracer

  TOP_CITIES = ['san francisco', 'london', 'new york', 'los angeles', 'chicago']

  def initialize(filters = {})
    if filters.fetch(:transactable_type_id, nil).blank?
      raise NotImplementedError.new('transactable_type_id filter is mandatory')
    end
    @midpoint = filters.fetch(:midpoint)
    @radius = filters.fetch(:radius)
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
    @locations_scope = @locations_scope.includes(:location_address).near(@midpoint, @radius, :order => "#{Address.order_by_distance_sql(@midpoint[0], @midpoint[1])} ASC") if @midpoint && @radius
    @locations_scope = @locations_scope.filtered_by_location_types_ids(@filters[:location_types_ids]) if @filters[:location_types_ids]
    @locations_scope = @locations_scope.filtered_by_industries_ids(@filters[:industries_ids]) if @filters[:industries_ids]
    @locations_scope
  end

  def filtered_listings
    @listings_scope = Transactable.searchable.where(transactable_type_id: @filters[:transactable_type_id])
    @listings_scope = @listings_scope.filtered_by_listing_types_ids(@filters[:listing_types_ids]) if @filters[:listing_types_ids]
    @listings_scope = @listings_scope.filtered_by_price_types(@filters[:listing_pricing] & (Transactable::PRICE_TYPES + [:free]).map(&:to_s)) if @filters[:listing_pricing]
    @listings_scope = @listings_scope.filtered_by_attribute_values(@filters[:attribute_values]) if @filters[:attribute_values]

    # Date pickers
    if availability_filter?
      if relative_availability?
        @listings_scope = @listings_scope.not_booked_relative(@filters[:date_range].first, @filters[:date_range].last)
      else
        @listings_scope = @listings_scope.not_booked_absolute(@filters[:date_range].first, @filters[:date_range].last)
      end

      # This one is ugly and slow as hell :o(
      if PlatformContext.current.instance.date_pickers_use_availability_rules
        @listings_scope = Transactable.where(id: @listings_scope.collect.select { |l| t_avail?(l) }.map(&:id))
      end
    end

    @listings_scope
  end

  def t_avail?(transactable)
    (@filters[:date_range].first..@filters[:date_range].last).each do |day|
      if relative_availability?
        return true if transactable.open_on?(day) # Returns the transactable if it's opened at least one day during the date range
      else
        return false unless transactable.open_on?(day) # Returns the transactable if it's opened for the whole date range
      end
    end

    !relative_availability?
  end

  def availability_filter?
    @filters[:availability] && @filters[:availability][:dates][:start].present? && @filters[:availability][:dates][:end].present?
  end

  def relative_availability?
    @relative ||= PlatformContext.current.instance.date_pickers_relative_mode?
  end
end
