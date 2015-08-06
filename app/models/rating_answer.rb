class RatingAnswer < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  has_paper_trail
  acts_as_paranoid

  belongs_to :rating_question
  belongs_to :review, touch: true
  belongs_to :instance

  validates_presence_of :rating_question_id, :review_id
  validates :rating, inclusion: { in: RatingConstants::VALID_VALUES }, allow_blank: true
end
