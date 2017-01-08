# frozen_string_literal: true
class ReviewDrop < BaseDrop
  # @return [ReviewDrop]
  attr_reader :review

  # @!method reviewable
  #   @return [Object] polymorphic object (can be of multiple types)
  # @!method rating
  #   @return [Integer] Numeric value for the overall rating
  # @!method comment
  #   @return [String] Comment provided by the reviewer
  # @!method date_format
  #   @return [String] Formatted created_at date, returning either "Today" or date in :short format
  delegate :reviewable, :rating, :comment, :date_format,
           to: :review

  def initialize(review)
    @review = review.decorate
  end

  # @return [Integer] max available rating value in the platform
  def max_rating
    RatingConstants::MAX_RATING
  end

  # @return [String] Description of the reviewed object
  def reviewable_info
    @review.show_reviewable_info
  end

  # @return [Array<Hash{String => String,Integer>] Collection of rating questions serialized into hash containing Question text and answer rating
  def questions
    @review.rating_system.rating_questions.select(:text, :id).map do |rating_question|
      {
        'text' => rating_question.text,
        'rating' => @review.rating_answers.find { |ra| ra.rating_question_id == rating_question.id }.try(:rating).to_i
      }
    end
  end
end
