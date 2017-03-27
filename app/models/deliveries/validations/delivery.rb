module Deliveries
  module Validations
    # in runtime finds adequate validator based on selected shipping provider
    class Delivery < ActiveModel::Validator
      def validate(record)
        validator_for(record.courier).validate(record)
      end

      def validator_for(courier)
        case courier
        when 'sendle' then sendle
        when 'manual' then manual
        when 'auspost-manual' then manual
        else
          default
        end
      end

      private

      def default
        DefaultDeliveryValidator.new
      end

      def manual
        Deliveries::Manual::Validations::Delivery.new
      end

      def sendle
        Deliveries::Sendle::Validations::Delivery.new
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
