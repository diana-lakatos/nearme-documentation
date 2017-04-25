# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class FormComponentConverter < BaseConverter
      include NewMarketplaceBuilder::FormComponentsBuilder

      primary_key :name
      properties :name
      property :fields
      property :type

      def type(form_component)
        form_component.form_type
      end

      def fields(form_component)
        form_component.form_fields.map(&:stringify_keys)
      end

      def import(data)
        update_form_components_for_object(@model, data)
      end

      def scope
        @model.form_components.order('id ASC')
      end
    end
  end
end
