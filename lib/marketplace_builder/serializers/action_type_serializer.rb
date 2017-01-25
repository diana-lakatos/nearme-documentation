module MarketplaceBuilder
  module Serializers
    class ActionTypeSerializer < BaseSerializer
      properties :enabled, :type, :allow_no_action

      serialize :pricings, using: TransactableTypePricingSerializer

      def scope
        @model.action_types
      end
    end
  end
end
