module MarketplaceBuilder
  module Serializers
    class RatingSystemSerializer < BaseSerializer
      resource_name -> (r) { "rating_systems/#{r.subject}" }

      properties :subject, :active
      property :transactable_type

      serialize :rating_questions, using: RatingQuestionSerializer
      serialize :rating_hints, using: RatingHintSerializer

      def transactable_type(rating_system)
        rating_system.transactable_type.name
      end

      def scope
        RatingSystem.where(instance_id: @model.id).all
      end
    end
  end
end
