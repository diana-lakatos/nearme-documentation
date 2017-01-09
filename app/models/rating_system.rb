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

  accepts_nested_attributes_for :rating_questions, reject_if: ->(attrs) { attrs['text'].blank? }, allow_destroy: true
  accepts_nested_attributes_for :rating_hints

  validates_inclusion_of :subject, in: RatingConstants::RATING_SYSTEM_SUBJECTS

  default_scope { order('active ASC') }

  scope :active, -> { where(active: true).joins(:transactable_type).where(transactable_types: { enable_reviews: true }) }
  scope :active_with_subject, ->(subject) { active.with_subject(subject) }
  scope :with_subject, -> (subject) { where(subject: subject) }
  scope :for_transactables, -> { where(subject: RatingConstants::TRANSACTABLE) }
  scope :for_hosts, -> { where(subject: RatingConstants::HOST) }
  scope :for_guests, -> { where(subject: RatingConstants::GUEST) }

  after_commit :expire_cache

  def expire_cache
    Rails.cache.delete_matched('reviews_view/*')
  end
end
