require 'holidays'

module Deliveries
  class Sendle
    module Validations
      class PickupBusinessDateValidator < ActiveModel::EachValidator
        def validate_each(record, attribute, value)
          return unless value

          record.errors.add attribute, :non_business_day if business_day?(value.to_date)
          record.errors.add attribute, :non_holiday_day if holiday?(value.to_date)
        rescue ArgumentError
          record.errors.add attribute, :invalid_format
        end

        def business_day?(date)
          date.sunday? || date.saturday?
        end

        def holiday?(date)
          Holidays.on(date, country_list).any?
        end

        def country_list
          :au
        end
      end
    end
  end
end
