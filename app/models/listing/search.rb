class Listing
  module Search

    extend ActiveSupport::Concern

    included do

      define_index do

        indexes :name, :description

        join location
        where  "locations.id is not null"

        has "radians(#{Location.table_name}.latitude)",  as: :latitude,  type: :float
        has "radians(#{Location.table_name}.longitude)", as: :longitude, type: :float

        has :deleted_at

        group_by :latitude, :longitude
      end

    end

    module ClassMethods

      def search_from_api(params, geocoder = nil)
        find_by_search_params(Params::Api.new(params, geocoder))
      end

      def search_from_web(params)
        find_by_search_params(Params::Web.new(params))
      end

      def find_by_search_params(params)
        search_args = if params.keyword_search?
          [params.query, params.to_scope]
        else
          [params.to_scope]
        end

        listings = search(*search_args).to_a
        listings.reject { |listing| params.availability.dates.any? { |date| listing.fully_booked_on?(date) } }
      end
    end
  end
end
