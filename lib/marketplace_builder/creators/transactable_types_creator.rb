# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class TransactableTypesCreator < ObjectTypesCreator
      private

      def object_class_name
        return "TransactableType"
      end
    end
  end
end
