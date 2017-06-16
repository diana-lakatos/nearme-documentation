# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class CustomAttributeConverter < BaseConverter
      include NewMarketplaceBuilder::CustomAttributesBuilder

      primary_key :name
      properties :name, :attribute_type, :html_tag, :search_in_query, :label, :searchable, :input_html_options, :public

      convert :validation, using: CustomValidationConverter

      def import(data)
        update_custom_attributes_for_object(@model, data)
      end

      def scope
        @model.custom_attributes
      end
    end
  end
end
