module MarketplaceBuilder
  module Serializers
    class CustomValidationSerializer < BaseSerializer
      properties :required, :field_name, :valid_values, :max_length, :min_length, :validation_only_on_update

      property :regex

      def regex(custom_validator)
        custom_validator.regex_expression
      end

      def before_serialize(custom_validator)
        custom_validator.set_accessors
      end

      def scope
        @model.custom_validators
      end
    end
  end
end
