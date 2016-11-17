# frozen_string_literal: true
require 'csv'

module Deliveries
  class Sendle
    module Validations
      class Address < ActiveModel::Validator
        def validate(record)
          validator_list.each { |validator| validator.validate(record) }
        end

        private

        def validator_list
          [
            presence_validator(attributes: [:city, :postcode, :country, :address]),
            pickup_location_validator
          ]
        end

        def pickup_location_validator
          PickupLocationValidator.new
        end

        def presence_validator(params)
          ActiveModel::Validations::PresenceValidator.new(params)
        end
      end

      class PickupLocationValidator < ActiveModel::Validator
        def validate(record)
          return if valid_pickup_location?(record)

          record.errors.add(:address, :invalid_pickup_location)
        end

        private

        def valid_pickup_location?(record)
          return unless record.city

          pickup_locations.any? do |_location, suburb, postcode, _state, _zone|
            suburb == normalize(record.city) && postcode == record.postcode
          end
        end

        def normalize(city)
          city.gsub(/^Saint\b/, 'St')
        end

        def pickup_locations
          @locations ||= CSV.read('./vendor/gems/sendle_api/sendle_pickup_locations.csv')
        end
      end
    end
  end
end
