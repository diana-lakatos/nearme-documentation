module MarketplaceBuilder
  module Serializers
    class RatingQuestionSerializer < BaseSerializer
      properties :text

      def scope
        @model.rating_questions
      end
    end
  end
end
