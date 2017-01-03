module MarketplaceBuilder
  module Serializers
    class FormComponentSerializer < BaseSerializer
      properties :name
      property :fields
      property :type

      def type(form_component)
        form_component.form_type
      end

      def fields(form_component)
        form_component.form_fields.map {|x| x.stringify_keys}
      end

      def scope
        @model.form_components
      end
    end
  end
end
