module Deliveries
  class Manual
    module Validations
      class Delivery < ActiveModel::Validator
        def validate(record)
          validator_list.each { |validator| validator.validate(record) }
        end

        private

        def validator_list
          [
            presence_validator(attributes: [:pickup_date, :sender_address, :receiver_address])
          ]
        end

        def presence_validator(params)
          ActiveModel::Validations::PresenceValidator.new(params)
        end
      end
    end
  end
end
