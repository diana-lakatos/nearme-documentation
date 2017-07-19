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
            pickup_busines_date_validator(attributes: [:pickup_date]),
            delivery_params_validator
          ]
        end

        def pickup_busines_date_validator(params)
          Deliveries::Sendle::Validations::PickupBusinessDateValidator.new(params)
        end

        def presence_validator(params)
          ActiveModel::Validations::PresenceValidator.new(params)
        end

        def delivery_params_validator
          DeliveryParamValidator.new
        end

        class DeliveryParamValidator < ActiveModel::Validator
          def validate(record)
            validator = Deliveries::Sendle::Validations::ValidatePlaceOrderRequest.new(record)

            return if validator.valid?

            validator.errors.each do |key, error|
              record.errors.add key, error if error
            end
          end
        end
      end
    end
  end
end
