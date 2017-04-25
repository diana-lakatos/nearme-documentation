# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class ActionTypeConverter < BaseConverter
      include NewMarketplaceBuilder::ActionTypesBuilder

      primary_key :type
      properties :enabled, :type, :allow_no_action

      convert :pricings, using: TransactableTypePricingConverter

      def import(data)
        update_action_types_for_object(@model, data)
      end

      def scope
        @model.action_types
      end
    end
  end
end
