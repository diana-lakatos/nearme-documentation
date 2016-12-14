module Deliveries
  class Sendle
    module Validations
      class Order < ActiveModel::Validator
        def validate(record)
          validator_list.each { |validator| validator.validate(record) }
        end

        private

        def validator_list
          [
            delivery_date_validator,
            pickup_busines_date_validator(attributes: [:dates_fake])
          ]
        end

        def delivery_date_validator
          DeliveryDateValidator.new
        end

        def pickup_busines_date_validator(params)
          Deliveries::Sendle::Validations::PickupBusinessDateValidator.new(params)
        end
      end

      # need better name for this
      # it is validator for possible pickup dates for specific valid delivery date
      # determines date range before delivery and validates against possibiblity of pickup
      class DeliveryDateValidator < ActiveModel::Validator
        def validate(record)
          return unless record.dates_fake
          return if valid_delivery_date?(record.dates_fake, record.transactable.location.location_address)

          record.errors.add(:dates_fake, :invalid_date_for_delivery)
        end

        def valid_delivery_date?(date, item_address)
          # this two could be combined into one service
          time_zone = ItemLocationTimeZone.new(item_address)
          range = PossiblePickupDates.new(time_zone: time_zone, to: date.to_date)

          range.any?
        end
      end
    end
  end
end
