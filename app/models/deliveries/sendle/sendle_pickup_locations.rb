module Deliveries
  class Sendle
    class SendlePickupLocations
      def initialize
      end

      def all
        pickup_locations
      end

      def postcodes
        pickup_locations.map(&:third)
      end

      def exist?(postcode:, suburb:, state:)
        all.any? do |row|
          row.fetch('Suburb') == normalize(suburb) && row.fetch('Postcode') == postcode && row.fetch('State') == state
        end
      end

      private

      def equal?(a, b)
        a.strip == b.strip
      end

      def pickup_locations
        @locations ||= CSV.read('./vendor/gems/sendle_api/sendle_pickup_locations.csv', headers: true)
      end

      def normalize(suburb)
        suburb.gsub(/^Saint\b/, 'St')
      end
    end
  end
end
