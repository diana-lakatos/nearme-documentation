class Listing
  class SearchFilterer

    # params_object - Object wrapping search options
    #          Needs to respond to:
    #           midpoint        - an array of two lat/lng points.
    #           radius          - a float representing the radius of the search
    #           available_dates - list of Date objects to filter the results for availability
    def initialize(search_scope, filters = {})
      @search_scope = search_scope
      @midpoint = filters.delete(:midpoint)
      @radius = filters.delete(:radius)
      @filters = filters
    end

    def find_listings
      filtered_locations.includes(:listings).inject([]) do |filtered_listings, location| 
        @listings = location.listings.searchable
        @listings = @listings.filtered_by_listing_type_ids(@filters[:listing_type_ids]) if @filters[:listing_type_ids]
        @listings.each do |listing|
          listing.distance_from_search_query = location.distance if location.respond_to?(:distance)
          filtered_listings << listing
        end
        filtered_listings
      end
    end

    private 
    def filtered_locations
      if @midpoint && @radius
        @search_scope = @search_scope.near(@midpoint, @radius, :order => :distance)
        @search_scope = @search_scope.filtered_by_location_types_ids(@filters[:location_types_ids]) if @filters[:location_types_ids]
        @search_scope = @search_scope.filtered_by_industries_ids(@filters[:industries_ids]) if @filters[:industries_ids]
      else
        @search_scope = @search_scope.none
      end
      @search_scope
    rescue
      @search_scope = @search_scope.none
      @search_scope
    end

    def reject_unavailable_listings
      @filters[:available_dates].each do |date|
        @listings.reject! { |listing| listing.fully_booked_on?(date) }
      end if @filters[:available_dates]
    end 

  end
end
