module MarketplaceBuilder
  module Serializers
    class CustomAttributeSerializer < BaseSerializer
      properties :name, :attribute_type, :html_tag, :search_in_query, :label, :searchable, :input_html_options

      serialize :validation, using: CustomValidationSerializer

      def scope
        @model.custom_attributes
      end
    end
  end
end
