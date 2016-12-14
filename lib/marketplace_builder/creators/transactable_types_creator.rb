# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class TransactableTypesCreator < ObjectTypesCreator
      def base_scope
        @instance.transactable_types.where.not(type: 'GroupType')
      end

      private

      def object_class_name
        'TransactableType'
      end
    end
  end
end
