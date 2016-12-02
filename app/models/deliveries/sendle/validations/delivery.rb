module Deliveries
  class Sendle
    module Validations
      class Delivery < ActiveModel::Validator
        def validate(record)
          validator_list.each { |validator| validator.validate(record) }
        end

        private

        def validator_list
          [
            presence_validator(attributes: [:pickup_date, :sender_address, :receiver_address]),
            pickup_date_validator
          ]
        end

        def pickup_date_validator
          PickupDateValidator.new
        end

        def presence_validator(params)
          ActiveModel::Validations::PresenceValidator.new(params)
        end
      end

      class PickupDateValidator < ActiveModel::Validator
        def validate(record)
          return unless record.pickup_date
          validate_pickup_date(record)
        end

        private

        def validate_pickup_date(record)
          record.errors.add :pickup_date, :pick_up_only_on_business_days if business_day?(record.pickup_date)
        end

        def business_day?(date)
          date.sunday? || date.saturday?
        end
      end
    end
  end
end
