# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class TransactableTypeFormComponentsCreator < FormComponentsCreator
      private

      def object_class_name
        'TransactableType'
      end
    end
  end
end
