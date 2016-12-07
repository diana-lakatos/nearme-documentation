# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class TransactableTypeCustomAttributesCreator < CustomAttributesCreator
      private

      def object_class_name
        'TransactableType'
      end
    end
  end
end
