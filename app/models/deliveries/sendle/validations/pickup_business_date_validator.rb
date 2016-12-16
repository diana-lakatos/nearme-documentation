module Deliveries
  class Sendle
    module Validations
      class PickupBusinessDateValidator < ActiveModel::EachValidator
        def validate_each(record, attribute, value)
          return unless value

          record.errors.add attribute, :non_business_day if business_day?(value.to_date)
        rescue ArgumentError
          record.errors.add attribute, :invalid_format
        end

        def business_day?(date)
          date.sunday? || date.saturday?
        end
      end
    end
  end
end
