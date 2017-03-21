module Deliveries
  class Sendle
    class SendlePickupLocations
      cattr_accessor :locations

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
        self.class.locations ||= CSV.read('./vendor/gems/sendle_api/sendle_pickup_locations.csv', headers: true).each_with_object([]) do |row, rows|
          rows << row

          if row['Suburb'].start_with? 'Mount '
            rows << copy_row(row).tap { |r| r['Suburb'] = r['Suburb'].gsub(/^Mount\ /, 'Mt ') }
            rows << copy_row(row).tap { |r| r['Suburb'] = r['Suburb'].gsub(/^Mount\ /, 'Mt. ') }
          end
        end
      end

      def copy_row(row)
        CSV::Row.new(row.headers, row.fields)
      end

      def normalize(suburb)
        suburb.gsub(/^Saint\b/, 'St')
      end
    end
  end
end
