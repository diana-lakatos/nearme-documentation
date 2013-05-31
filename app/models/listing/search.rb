class Listing
  module Search

    extend ActiveSupport::Concern

    module ClassMethods

      def search_from_api(params, geocoder = nil)
        find_by_search_params(Params::Api.new(params))
      end

      def search_from_web(params)
        find_by_search_params(Params::Web.new(params))
      end

      # Takes a search parameters object and returns matching Listing results.
      #
      # params - Object wrapping search options
      #          Needs to respond to:
      #           midpoint        - an array of two lat/lng points.
      #           radius          - a float representing the radius of the search
      #           available_dates - list of Date objects to filter the results for availability
      def find_by_search_params(params)
        midpoint = params.midpoint
        radius   = params.radius

        # If no geolocation point, then no results
        return [] unless midpoint && radius

        locations = Location.near(midpoint, radius)
        return [] unless locations.any?

        # Load listings
        listings = Listing.where(:location_id => locations.map(&:id)).includes(:photos)

        # Remove listings unavailable
        params.available_dates.each do |date|
          listings.reject! { |listing| listing.fully_booked_on?(date) }
        end

        listings
      end
    end
  end
end
