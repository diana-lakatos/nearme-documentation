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
        @listings_scope = @listings_scope.only_opened_on_at_least_one_of(date_range_to_days)
      else
        @listings_scope = @listings_scope.not_booked_absolute(@filters[:date_range].first, @filters[:date_range].last)
        @listings_scope = @listings_scope.only_opened_on_all_of(date_range_to_days)
      end
    end

    @listings_scope = Transactable.where(id: @listings_scope.pluck(:id))
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
