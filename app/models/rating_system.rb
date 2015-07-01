class RatingSystem < ActiveRecord::Base
  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid

  belongs_to :transactable_type
  belongs_to :instance
  has_many :rating_questions, dependent: :destroy
  has_many :rating_hints, dependent: :destroy
  has_many :reviews, dependent: :destroy

  accepts_nested_attributes_for :rating_questions, reject_if: lambda { |attrs| attrs['text'].blank? }, allow_destroy: true
  accepts_nested_attributes_for :rating_hints

  default_scope { order('active ASC') }

  scope :active, -> { where(active: true) }
  scope :active_with_subject, ->(subject) { active.find_by(subject: subject) }
end
