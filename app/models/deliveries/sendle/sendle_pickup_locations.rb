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

      def exist?(postcode:, suburb:)
        all.any? do |row|
          row['Suburb'] == normalize(suburb) && row['Postcode'] == postcode
        end
      end

      private

      def pickup_locations
        @locations ||= CSV.read('./vendor/gems/sendle_api/sendle_pickup_locations.csv', headers: true)
      end

      def normalize(suburb)
        suburb.gsub(/^Saint\b/, 'St')
      end
    end
  end
end
