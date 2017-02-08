# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class RatingSystemCreator < DataCreator
      def execute!
        rating_systems = get_data
        return if rating_systems.empty?

        rating_systems.keys.each do |key|
          rating_system_attributes = rating_systems[key]
          rating_questions = rating_system_attributes.delete('rating_questions')
          rating_hints = rating_system_attributes.delete('rating_hints')
          rating_system = create_or_update_rating_system(rating_system_attributes)

          rating_questions.each do |rating_question_attributes|
            create_or_update_rating_question(rating_system, rating_question_attributes)
          end if rating_questions

          rating_hints.each do |rating_hint_attributes|
            create_or_update_rating_hint(rating_system, rating_hint_attributes)
          end if rating_hints
        end
      end

      def cleanup!
        RatingSystem.delete_all
        RatingHint.delete_all
        RatingQuestion.delete_all
      end

      private

      def create_or_update_rating_system(rating_system_attributes)
        rating_system = RatingSystem.where(subject: rating_system_attributes['subject']).first_or_initialize
        rating_system.transactable_type = TransactableType.find_by name: rating_system_attributes.delete('transactable_type')

        rating_system.assign_attributes rating_system_attributes
        rating_system.save!
        rating_system
      end

      def create_or_update_rating_question(rating_system, rating_question_attributes)
        rating_system.rating_questions.where(text: rating_question_attributes['text']).first_or_create!
      end

      def create_or_update_rating_hint(rating_system, rating_hint_attributes)
        rating_hint = rating_system.rating_hints.where(value: rating_hint_attributes['value']).first_or_initialize
        rating_hint.assign_attributes rating_hint_attributes
        rating_hint.save!
      end

      def source
        File.join('rating_systems')
      end
    end
  end
end
