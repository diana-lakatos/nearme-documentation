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
    @listings_scope = @listings_scope.available_on(@filters[:date_range].first, @filters[:date_range].last) if availability_filter?
    @listings_scope
  end

  def availability_filter?
    @filters[:availability] && @filters[:availability][:dates][:start].present? && @filters[:availability][:dates][:end].present?
  end
end
