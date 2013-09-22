class Listing
  module Search

    extend ActiveSupport::Concern

    module ClassMethods

      def search_from_api(params, scoped_locations)
        find_by_search_params(Params::Api.new(params), scoped_locations)
      end

      def search_from_web(params, scoped_locations)
        find_by_search_params(Params::Web.new(params), scoped_locations)
      end

      # Takes a search parameters object and returns matching Listing results.
      #
      # params - Object wrapping search options
      #          Needs to respond to:
      #           midpoint        - an array of two lat/lng points.
      #           radius          - a float representing the radius of the search
      #           available_dates - list of Date objects to filter the results for availability
      def find_by_search_params(params, scoped_locations = LocationPolicy.scope)
        midpoint = params.midpoint
        radius   = params.radius

        # If no geolocation point, then no results
        return [] unless midpoint && radius

        locations = scoped_locations.near(midpoint, radius, :order => :distance).includes(:listings)
        return [] unless locations.any?

        locations.inject([]) do |filtered_listings, location| 
          listings =  location.listings.active.visible
          params.available_dates.each do |date|
            listings.reject! { |listing| listing.fully_booked_on?(date) }
          end
          listings.each do |listing|
            listing.distance_from_search_query = location.distance if location.respond_to?(:distance)
            filtered_listings << listing
          end
          filtered_listings
        end
      end
    end
  end
end
