class Listing
  module Search

    class SearchTypeNotSupported < StandardError; end

    extend ActiveSupport::Concern

    included do
      # score is to be used by searches. It isn't persisted.
      # Ignore it for the most part.
      attr_accessor :score

      # strict_match is used to indicate search results that match all relevant criteria
      attr_accessor :strict_match

      # thinking sphinx index
      define_index do
        join location

        indexes :name, :description

        has "radians(#{Location.table_name}.latitude)",  as: :latitude,  type: :float
        has "radians(#{Location.table_name}.longitude)", as: :longitude, type: :float

        group_by :latitude, :longitude
      end
    end

    module ClassMethods

      def find_by_search_params(params)
        params.symbolize_keys!

        listings = if params.has_key?(:boundingbox)
          find_by_boundingbox(params.delete(:boundingbox))
        elsif params.has_key?(:query)
          find_by_keyword(params.delete(:query))
        else
          raise SearchTypeNotSupported.new("You must specify either a bounding box or keywords to search by")
        end

        # now score listings
        Scorer.score(listings, params)

        # return scored listings
        listings
      end

      # TODO: Roll this into Sphinx search (used by web frontend)
      def search_by_location(search)
        return self if search[:lat].nil? || search[:lng].nil?

        distance = if (search[:southwest] && search[:southwest][:lat] && search[:southwest][:lng]) &&
                      (search[:northeast] && search[:northeast][:lat] && search[:northeast][:lng])
          Geocoder::Calculations.distance_between([ search[:southwest][:lat].to_f, search[:southwest][:lng].to_f ],
                                                  [ search[:northeast][:lat].to_f, search[:northeast][:lng].to_f ], units: :km)
        else
          30
        end
        Location.near([ search[:lat].to_f, search[:lng].to_f ], distance, order: "distance", units: :km)
      end

      private

        # we use Sphinx's geosearch here, which takes a midpoint and radius
        def find_by_boundingbox(boundingbox)
          boundingbox.symbolize_keys!
          boundingbox = boundingbox.inject({}) { |r, h| k, v = h; r[k] = v.symbolize_keys!; r } # my kingdom for deep_symbolize_keys...

          north_west = [boundingbox[:start][:lat], boundingbox[:start][:lon]]
          south_east = [boundingbox[:end][:lat],   boundingbox[:end][:lon]]

          midpoint         = Geocoder::Calculations.geographic_center([north_west, south_east])
          radius_m         = Geocoder::Calculations.distance_between(north_west, midpoint) * 1_000

          # sphinx needs the coordinates in radians
          midpoint_radians = Geocoder::Calculations.to_radians(midpoint)

          search(
            geo:  midpoint_radians,
            with: { "@geodist" => 0.0...radius_m.to_f }
          )
        end

        def find_by_keyword(query)
          # sphinx :)
          search(query)
        end

    end
  end
end