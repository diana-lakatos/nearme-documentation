class Listing
  class SearchScope

    attr_accessor :filters, :search_params
    def initialize(instance, options = {})
      @instance = instance
      @options = options
      @current_scope = if @options[:white_label_company].try(:white_label_enabled?)
        Location.where(:"locations.company_id" => white_label_company.id)
      else
        Location.joins(:company).where(companies: { listings_public: true, instance_id: @instance.id })
      end
    end

    # params_object - Object wrapping search options
    #          Needs to respond to:
    #           midpoint        - an array of two lat/lng points.
    #           radius          - a float representing the radius of the search
    #           available_dates - list of Date objects to filter the results for availability
    def find_listings(params_object, filters = {})
      @search_params = params_object
      @filters = filters
      locations.includes(:listings).inject([]) do |filtered_listings, location| 
        listings =  location.listings.searchable
        @search_params.available_dates.each do |date|
          listings.reject! { |listing| listing.fully_booked_on?(date) }
        end
        listings.each do |listing|
          listing.distance_from_search_query = location.distance if location.respond_to?(:distance)
          filtered_listings << listing
        end
        filtered_listings
      end
    end

    def locations
      if apply_geocoding
        apply_filters if @filters
        @current_scope
      else
        Location.none
      end
    end

    def apply_geocoding
      return nil unless @search_params.try(:midpoint) && @search_params.try(:radius)
      @current_scope = @current_scope.near(@search_params.midpoint, @search_params.radius, :order => :distance)
    end

    def apply_filters
      @filters.each do |filter_type, value|
        @current_scope = @current_scope.send("filtered_by_#{filter_type}", value)
      end
      @current_scope = @current_scope.uniq
    end
  end
end
