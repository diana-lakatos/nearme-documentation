module Deliveries
  class Sendle
    module Validations
      class ItemLocationTimeZone
        def initialize(address)
          @address = address
        end

        def now
          time_zone.now
        end

        def name
          time_zone.name
        end

        private

        def time_zone
          @tz ||= ActiveSupport::TimeZone[time_zone_name]
        end

        def time_zone_name
          return unless coordinates

          NearestTimeZone.to(*coordinates.values)
        end

        def coordinates
          return unless geolocation

          geolocation.data['geometry']['location']
        end

        def geolocation
          Geocoder.search(full_address).first
        end

        def full_address
          [@address.postcode, @address.suburb, @address.state, @address.country].join(' ')
        end
      end
    end
  end
end
