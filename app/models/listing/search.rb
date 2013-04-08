class Listing
  module Search

    extend ActiveSupport::Concern

    module ClassMethods

      def search_from_api(params, geocoder = nil)
        find_by_search_params(Params::Api.new(params, geocoder))
      end

      def search_from_web(params)
        find_by_search_params(Params::Web.new(params))
      end

      def find_by_search_params(params)
        return [] unless params.found_location?
        
        args = params.to_args
        locations = Location.near(*args)
        return [] unless locations.any?
        
        listings = Listing.where(["listings.location_id IN(?)", locations.map(&:id)]).includes(:photos)
        
        params.availability.dates.each do |date|
          listings.reject! { |listing| listing.fully_booked_on?(date) }
        end
        
        listings
      end
    end
  end
end
