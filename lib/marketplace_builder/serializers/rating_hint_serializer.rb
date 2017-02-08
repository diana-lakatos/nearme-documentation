module MarketplaceBuilder
  module Serializers
    class RatingHintSerializer < BaseSerializer
      properties :value, :description

      def scope
        @model.rating_hints
      end
    end
  end
end
