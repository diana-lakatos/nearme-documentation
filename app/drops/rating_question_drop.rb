# frozen_string_literal: true
class RatingQuestionDrop < BaseDrop
  # @return [RatingQuestionDrop]
  attr_reader :rating_question

  # @!method text
  #   @return [String] Rating question body
  # @!method id
  #   @return [Integer] Object identifier
  delegate :text, :id,
           to: :rating_question

  def initialize(rating_question)
    @rating_question = rating_question
  end
end
