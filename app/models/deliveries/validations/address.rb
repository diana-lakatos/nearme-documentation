module Deliveries
  module Validations
    # in runtime finds adequate validator based on selected shipping provider
    class Address < ActiveModel::Validator
      def validate(record)
        validator_for('sendle').validate(record)
      end

      def validator_for(courier)
        send courier || :default
      end

      private

      def default
        DefaultDeliveryValidator.new
      end

      def sendle
        Deliveries::Sendle::Validations::Address.new
      end
    end

    # it a null-object-like validator
    class DefaultDeliveryValidator < ActiveModel::Validator
      def validate(record)
        # as default no validations
      end
    end
  end
end
