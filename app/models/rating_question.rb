# frozen_string_literal: true
class RatingQuestion < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  has_paper_trail
  acts_as_paranoid

  belongs_to :rating_system
  belongs_to :instance
  has_many :rating_answers, dependent: :destroy

  validates :text, presence: true

  default_scope { order('id ASC') }

  after_create :create_empty_answers

  def to_liquid
    @rating_question_drop ||= RatingQuestionDrop.new(self)
  end

  private

  def create_empty_answers
    rating_system.reviews.pluck(:id).each do |review_id|
      rating_answers.create!(review_id: review_id)
    end
  end
end
