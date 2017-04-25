# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class CustomValidationConverter < BaseConverter
      include NewMarketplaceBuilder::CustomValidatorsBuilder

      primary_key :field_name
      properties :required, :field_name, :valid_values, :max_length, :min_length, :validation_only_on_update

      property :regex

      def regex(custom_validator)
        custom_validator.regex_expression
      end

      def before_serialize(custom_validator)
        custom_validator.set_accessors
      end

      def import(data)
        update_custom_validators_for_object(@model, data)
      end

      def scope
        @model.custom_validators
      end
    end
  end
end
