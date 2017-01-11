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
            presence_validator(attributes: [:suburb, :postcode, :country, :address, :state]),
            inclusion_validator(attributes: [:country], in: ['Australia']),
            pickup_location_validator
          ]
        end

        def inclusion_validator(params)
          ActiveModel::Validations::InclusionValidator.new(params)
        end

        def format_validator(params)
          ActiveModel::Validations::FormatValidator.new(params)
        end

        def pickup_location_validator
          PickupLocationValidator.new
        end

        def presence_validator(params)
          ActiveModel::Validations::PresenceValidator.new(params)
        end
      end
    end
  end
end
