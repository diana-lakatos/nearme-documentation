class Listing
  class SearchFetcher
    extend ::NewRelic::Agent::MethodTracer

    TOP_CITIES = ['san francisco', 'london', 'new york', 'los angeles', 'chicago']

    def initialize(search_scope, filters = {})
      @search_scope = search_scope
      @midpoint = filters.fetch(:midpoint)
      @radius = filters.fetch(:radius)
      @filters = filters
    end

    def listings
      @listings ||=
        begin
          locations = filtered_locations
          filtered_listings = Listing.searchable.where(location_id: locations.map(&:id))
          filtered_listings = filtered_listings.filtered_by_listing_types_ids(@filters[:listing_types_ids]) if @filters[:listing_types_ids]
          filtered_listings = filtered_listings.filtered_by_price_types(@filters[:listing_pricing] & Listing::PRICE_TYPES.map(&:to_s)) if @filters[:listing_pricing]
          self.class.trace_execution_scoped(['Custom/SearchFetcher/listings/filtered_listings']) do
            filtered_listings = filtered_listings.all
          end

          self.class.trace_execution_scoped(['Custom/SearchFetcher/listings/iterate_filtered_listings']) do
            filtered_listings.each do |listing|
              location = locations.detect { |l| l.id == listing.location_id } # Could be faster with a hash table
              listing.location = location # Cache location association without query
            end
          end
          self.class.trace_execution_scoped(['Custom/SearchFetcher/listings/sort_by_distance']) do
            filtered_listings.sort_by! {|l| l.location.distance } if filtered_listings.first.try(:location).try(:respond_to?, :distance)
          end

          # Order in top cities
          self.class.trace_execution_scoped(['Custom/SearchFetcher/listings/sort_by_top_citites']) do
            if !@filters[:query].blank? && TOP_CITIES.any?{|city| @filters[:query].downcase.include?(city)}
              filtered_listings = filtered_listings.sort_by(&:rank).reverse
            end
          end

          filtered_listings
        end
    end

    def locations
      @locations ||=
        begin
          _locations = Location.where(id: listings.map(&:location_id).uniq).includes(:company)
          _locations = _locations.near(@midpoint, @radius, :order => 'distance ASC') if @midpoint && @radius
          listings.each do |listing|
            _location = _locations.detect { |l| l.id == listing.location_id }
            _location.searched_locations ||= []
            _location.searched_locations << listing
          end

          if @filters[:sort].relevance?
            # do nothing, already ordered by distance
          else
            self.class.trace_execution_scoped(['Custom/SearchFetcher/locations/sort_by_price']) do
              _locations.sort_by! {|l| (l.lowest_price || [Money.new(0)])[0] }
            end
          end

          _locations
        end
    end

    private 
    def filtered_locations
      @search_scope = @search_scope.near(@midpoint, @radius, :order => 'distance ASC') if @midpoint && @radius
      @search_scope = @search_scope.filtered_by_location_types_ids(@filters[:location_types_ids]) if @filters[:location_types_ids]
      @search_scope = @search_scope.filtered_by_industries_ids(@filters[:industries_ids]) if @filters[:industries_ids]
      @search_scope
    end

    def reject_unavailable_listings
      return if @filters[:available_dates].blank?
      @filters[:available_dates].each do |date|
        @listings.reject! { |listing| listing.fully_booked_on?(date) }
      end 
    end 

  end
end
