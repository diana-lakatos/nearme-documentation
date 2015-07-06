class RatingQuestion < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  has_paper_trail
  acts_as_paranoid

  belongs_to :rating_system
  belongs_to :instance
  has_many :rating_answers, dependent: :destroy

  validates_presence_of :text

  default_scope { order('id ASC') }

  validate :check_questions_quantity, on: :create

  after_create :create_empty_answers

  private

  def create_empty_answers
    rating_system.reviews.pluck(:id).each do |review_id|
      rating_answers.create!(review_id: review_id)
    end
  end

  def check_questions_quantity
    if rating_system && rating_system.rating_questions.count >= RatingConstants::MAX_QUESTIONS_QUANTITY
      errors.add(:rating_system, I18n.t('rating_question.validation.question_quantity', number: RatingConstants::MAX_QUESTIONS_QUANTITY))
    end
  end
end
