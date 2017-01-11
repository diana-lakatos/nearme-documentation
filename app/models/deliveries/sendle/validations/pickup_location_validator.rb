module Deliveries
  class Sendle
    module Validations
      class PickupLocationValidator < ActiveModel::Validator
        def validate(record)
          return if valid_pickup_location?(record)

          record.errors.add(:postcode, :invalid_pickup_location)
          record.errors.add(:suburb, :invalid_pickup_location)
          record.errors.add(:state, :invalid_pickup_location)
        end

        private

        def valid_pickup_location?(record)
          return unless record.suburb
          return unless record.postcode
          return unless record.state

          sendle_pickup_locations.exist?(postcode: record.postcode.strip, suburb: record.suburb.strip, state: record.state.strip)
        end

        def pickup_locations
          sendle_pickup_locations.all
        end

        def postcodes
          sendle_pickup_locations.postcodes
        end

        def sendle_pickup_locations
          @sendle_pickup_locations ||= Deliveries::Sendle::SendlePickupLocations.new
        end
      end
    end
  end
end
